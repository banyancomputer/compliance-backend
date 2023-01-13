/* elb.tf: set up stage-based dns + ssl + alb for our django app
 * The domain pointed to by var.domain_name must be managed by Route53 before running this
 * If stage != 'prod' then the ELB will accessible at https://<stage>.<primary_domain_name>
 * If stage == prod then the ELB will be accessible at https://<primary_domain_name>
 */

/* Create a new certificate for the domain we want to host the ELB under */

# Pull data on the primary dns zone for the domain
# This hosted zone must already exist in Route53 and be configured appropriately with your domain registrar
# See https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html for more info
data "aws_route53_zone" "primary" {
  name = var.domain_name
}
# Create a DNS zone for the subdomain we want to host the ELB under (if applicable)
resource "aws_route53_zone" "stage" {
  count   = var.stage == "prod" ? 0 : 1
  name    = "${var.stage}.${var.domain_name}"
  comment = "DNS zone for ${var.stage}.${var.domain_name}"

  tags = {
    Name = "${var.stage}.${var.domain_name}"
  }
}
# Create a new DNS record for the hosted zone (if applicable)
resource "aws_route53_record" "stage_ns" {
  count   = var.stage == "prod" ? 0 : 1
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.stage}.${var.domain_name}"
  type    = "NS"
  ttl     = "172800"
  records = aws_route53_zone.stage[0].name_servers
}
# Generate an ACM certificate for the appropriate domain
resource "aws_acm_certificate" "stage_cert" {
  # If this is a prod stage, use the prod domain
  domain_name       = var.stage == "prod" ? var.domain_name : "${var.stage}.${var.domain_name}"
  validation_method = "DNS"
}
# Create a DNS record to prove that we _own_ the domain
resource "aws_route53_record" "stage_validate" {
  for_each = {
    for dvo in aws_acm_certificate.stage_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.stage == "prod" ? data.aws_route53_zone.primary.zone_id : aws_route53_zone.stage[0].zone_id
}
# Validate the certificate
resource "aws_acm_certificate_validation" "stage" {
  certificate_arn         = aws_acm_certificate.stage_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.stage_validate : record.fqdn]
}

/* Create a new load balancer for the the django app */

# Create a security group for the load balancer
resource "aws_security_group" "elb" {
  name        = join("-", [var.name, "elb-sg", var.stage, var.deploy_id])
  description = "Allow inbound traffic from the internet over HTTPS. Manage access to the app via the django app."
  vpc_id      = aws_vpc.vpc.id

  # Allow inbound and outbound traffic from the internet over HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound and outbound traffic over HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    deploy_id    = var.deploy_id
    stage        = var.stage
    service_name = var.name
    name         = join("-", [var.name, "elb-sg"])
  }
}
# Create a load balancer for the django app
resource "aws_elb" "elb" {
  name    = join("-", [var.name, "elb", var.stage, var.deploy_id])
  subnets = [
    aws_subnet.public.id,
  ]
  security_groups = [aws_security_group.elb.id]

  depends_on = [
    aws_acm_certificate.stage_cert
  ]

  # Listen to our Django app on port 80
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate_validation.stage.certificate_arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                 = [aws_instance.ec2.id]
  cross_zone_load_balancing = true
  idle_timeout              = 400

  tags = {
    deploy_id    = var.deploy_id
    stage        = var.stage
    service_name = var.name
    name         = join("-", [var.name, "elb"])
  }
}
# Add a DNS record for the load balancer
resource "aws_route53_record" "elb" {
  zone_id = var.stage == "prod" ? data.aws_route53_zone.primary.zone_id : aws_route53_zone.stage[0].zone_id
  name    = var.stage == "prod" ? var.domain_name : "${var.stage}.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_elb.elb.dns_name
    zone_id                = aws_elb.elb.zone_id
    evaluate_target_health = false
  }
}