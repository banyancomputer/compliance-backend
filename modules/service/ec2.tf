/* ec2.tf: Configuration and deployment of EC2 instance */

# Security group for managing access to the EC2 instance
resource "aws_security_group" "ec2" {
  name        = join("-", [var.name, "ec2-sg", var.stage, var.deploy_id])
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  # RDS - allow inbound and outbound traffic from the RDS security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [
      aws_security_group.rds.id
    ]
  }
  # SSH - allows provisioning and debugging TODO: Restrict to CI/CD server
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP - allows access to the application through the load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS - allows ec2 to talk to surrounding services
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    deploy_id    = var.deploy_id
    service_name = var.name
    stage        = var.stage
    name         = join("-", [var.name, "ec2-sg"])
  }
}
# TLS Key pair to use for the EC2 instance. Saves the private key to the local file system. Keep this safe!
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "null_resource" "ec2-key-write" {
  triggers = {
    key_file_path = "~/.ssh/${join("-", [var.name, "ec2-key", var.stage, var.deploy_id])}.pem"
  }

  # Save the private key to a file
  provisioner "local-exec" {
    command = "echo '${tls_private_key.ec2.private_key_pem}' > ${self.triggers.key_file_path} && chmod 600 ${self.triggers.key_file_path}"
  }

  # Destroy the private key file when the resource is destroyed
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${self.triggers.key_file_path}"
  }
}
# Key pair to use for the EC2 instance
resource "aws_key_pair" "ec2" {
  key_name   = join("-", [var.name, "ec2-key", var.stage, var.deploy_id])
  public_key = tls_private_key.ec2.public_key_openssh
  tags       = {
    deploy_id    = var.deploy_id
    service_name = var.name
    stage        = var.stage
    name         = join("-", [var.name, "ec2-key"])
  }
}
# IAM Role for the EC2 instance
resource "aws_iam_role" "ec2" {
  name               = join("-", [var.name, "ec2-role", var.stage, var.deploy_id])
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
    deploy_id = var.deploy_id
    service   = var.name
    stage     = var.stage
    name      = join("-", [var.name, "ec2-role"])
  }
}
# Instance profile for the EC2 instance. References the IAM role
resource "aws_iam_instance_profile" "ec2" {
  name = join("-", [var.name, "ec2-profile", var.stage, var.deploy_id])
  role = aws_iam_role.ec2.name
  tags = {
    deploy_id = var.deploy_id
    service   = var.name
    stage     = var.stage
    name      = join("-", [var.name, "ec2-profile"])
  }
}
# Policy for the Ec2 instance, attached to the IAM role
resource "aws_iam_role_policy" "ec2" {
  name   = join("-", [var.name, "ec2-policy", var.stage, var.deploy_id])
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
          # Allows our Ec2 instance to read and write to S3
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
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
    deploy_id    = var.deploy_id
    service_name = var.name
    stage        = var.stage
    name         = join("-", [var.name, "ec2"])
  }
}
# Elastic IP for accessing the EC2 instance
resource "aws_eip" "ec2" {
  instance = aws_instance.ec2.id
  vpc      = true

  tags = {
    deploy_id    = var.deploy_id
    service_name = var.name
    stage        = var.stage
    name         = join("-", [var.name, "ec2-eip"])
  }
}