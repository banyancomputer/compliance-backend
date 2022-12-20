# Main VPC and network configuration

# Terraform Config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.3.0"

  # TODO: Add encrypted backend
}
# Provider Configuration
provider "aws" {
  region = var.aws_region
}
# Who's launching all this Infra
data "aws_caller_identity" "current" {}
## Get the Available AZs
#data "aws_availability_zones" "available" {
#  state = "available"
#}

/* VPC */
#resource "aws_vpc" "vpc" {
#  # Set the CIDR block (the address space) for the VPC
#  cidr_block           = var.vpc_cidr_block
#  # Allow DNS hostnames to be created in the VPC (i.e. allow instances to have hostnames)
#  enable_dns_hostnames = true
#  tags                 = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "vpc"])
#  }
#}

/* Internet Gateway */
#resource "aws_internet_gateway" "igw" {
#  vpc_id = aws_vpc.vpc.id
#  tags   = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "igw"])
#  }
#}

#resource "aws_subnet" "public" {
#  count = var.subnet_count.public
#  vpc_id = aws_vpc.vpc.id
#  cidr_block = var.public_subnet_cidrs[count.index]
#  availability_zone = data.aws_availability_zones.available.names[count.index]
#  tags = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "public", count.index])
#  }
#}

#resource "aws_subnet" "private" {
#  count             = var.subnet_count.private
#  vpc_id            = aws_vpc.vpc.id
#  cidr_block        = var.private_subnet_cidrs[count.index]
#  availability_zone = data.aws_availability_zones.available.names[count.index]
#  tags              = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "private-subnet", count.index])
#  }
#}

/* Routing Table */
#resource "aws_route_table" "rt" {
#  vpc_id = aws_vpc.vpc.id
#  # Declare a route for the Internet Gateway
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.igw.id
#  }
#  tags = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "rt"])
#  }
#}
#
#resource "aws_route_table_association" "public" {
#  count          = var.subnet_count.public
#  subnet_id      = aws_subnet.public[count.index].id
#  route_table_id = aws_route_table.rt.id
#}

#resource "aws_route_table_association" "private" {
#  count          = var.subnet_count.private
#  subnet_id      = aws_subnet.private[count.index].id
#  route_table_id = aws_route_table.rt.id
#}

## TODO: (amiller68) - Custom domain name routing for exposed resources
#resource "aws_acm_certificate" "ec2" {
#  domain_name       = var.app.api_hostname
#  validation_method = "DNS"
#}
#
#data "aws_route53_zone" "ec2" {
#  name = var.app.api_hostname
#}
#
#resource "aws_route53_record" "ec2" {
#  for_each = {
#  for dvo in aws_acm_certificate.ec2.domain_validation_options : dvo.domain_name => {
#    name   = dvo.resource_record_name
#    record = dvo.resource_record_value
#    type   = dvo.resource_record_type
#  }
#  }
#
#  allow_overwrite = true
#  name            = each.value.name
#  records         = [each.value.record]
#  ttl             = 60
#  type            = each.value.type
#  zone_id         = data.aws_route53_zone.ec2.zone_id
#}
#
#resource "aws_acm_certificate_validation" "ec2" {
#  certificate_arn         = aws_acm_certificate.ec2.arn
#  validation_record_fqdns = [for record in aws_route53_record.ec2 : record.fqdn]
#}