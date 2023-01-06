/* ec2.tf: Configuration and deployment of EC2 instance */

# Security group for managing access to the EC2 instance
resource "aws_security_group" "ec2" {
  name        = join("-", [var.app.name, "ec2-sg", var.deploy_id])
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  # TODO - restrict to only whatever API Gateway needs
  # RDS
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [
      aws_security_group.rds.id
    ]
  }
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "ec2-sg"])
  }
}

# TLS Key pair to use for the EC2 instance
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096

  # Save the private key to a file
  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > ~/.ssh/${var.app.name}-ec2-key.pem && chmod 600 ~/.ssh/${var.app.name}-ec2-key.pem"
  }
}
# Key pair to use for the EC2 instance
resource "aws_key_pair" "ec2" {
  key_name   = join("-", [var.app.name, "ec2-key", var.deploy_id])
  public_key = tls_private_key.ec2.public_key_openssh
}
# IAM Role for the EC2 instance
resource "aws_iam_role" "ec2" {
  name               = join("-", [var.app.name, "ec2-role", var.deploy_id])
  #  "I can assume the role of an EC2 instance" policy
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Sid = ""
      }
    ]
  })
  tags = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "ec2-role"])
  }
}
# Instance profile for the EC2 instance. References the IAM role
resource "aws_iam_instance_profile" "ec2" {
  name = join("-", [var.app.name, "ec2-profile", var.deploy_id])
  role = aws_iam_role.ec2.name
  tags = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "ec2-profile"])
  }
}
# Policy for the Ec2 instance, attached to the IAM role
resource "aws_iam_role_policy" "ec2" {
  name   = join("-", [var.app.name, "ec2-policy", var.deploy_id])
  role   = aws_iam_role.ec2.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          # Allows our Ec2 instance to read from ECR
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ],
        Resource : "*"
      }
    ]
  })
}
# Definition of the Amazon Machine Image (AMI) to use for the EC2 instance
data "aws_ami" "ec2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    # We want something with hardware virtualization support, on x86_64, using gp2 storage
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# (Finally) The EC2 Instance itself
resource "aws_instance" "ec2" {
  # Configure the instance
  instance_type = var.ec2_config.instance_type
  monitoring    = tobool(var.ec2_config.monitoring)
  root_block_device {
    volume_size = tonumber(var.ec2_config.volume_size)
    volume_type = var.ec2_config.volume_type
  }
  # Link our Dependencies
  ami                    = data.aws_ami.ec2.id
  key_name               = aws_key_pair.ec2.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.public.id

  tags = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "ec2"])
  }
}
# Elastic IP for accessing the EC2 instance
resource "aws_eip" "ec2" {
  instance = aws_instance.ec2.id
  vpc      = true

  tags = {
    project       = var.app.name
    deployment_id = var.deploy_id
    Name          = join("-", [var.app.name, "ec2-eip"])
  }
}

resource "null_resource" "ec2" {
  triggers = {
    app_version = var.app.version
  }

  # Provision Our services with Ansible
  provisioner "local-exec" {
    command = <<-EOT
      export ANSIBLE_HOST_KEY_CHECKING=False
      ansible-playbook \
        -i ${aws_eip.ec2.public_dns}, \
        -u ec2-user \
        --private-key ~/.ssh/${var.app.name}-ec2-key.pem \
        --extra-vars "app=${var.app.name}" \
        --extra-vars "app_version=${var.app.version}" \
        --extra-vars "aws_region=${var.aws_region}" \
        --extra-vars "aws_account_id=${data.aws_caller_identity.current.account_id}" \
        --extra-vars "django_debug=${var.django_env.debug}" \
        --extra-vars "django_secret_key=${var.django_env.secret_key}" \
        --extra-vars "django_allowed_hosts=${var.django_env.allowed_hosts}" \
        --extra-vars "django_sql_engine=${var.django_env.sql_engine}" \
        --extra-vars "django_sql_database=${var.rds_config.engine}" \
        --extra-vars "django_sql_user=${var.rds_user}" \
        --extra-vars "django_sql_password=${var.rds_password}" \
        --extra-vars "django_sql_host=${split(":", aws_db_instance.rds.endpoint)[0]}" \
        --extra-vars "django_sql_port=${split(":", aws_db_instance.rds.endpoint)[1]}" \
        --extra-vars "django_database_type=${var.rds_config.engine}" \
        ${var.ec2_config.ansible_playbook}
    EOT
  }
}