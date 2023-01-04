/* main.tf: Deploys our service and surrounding networking infrastructure in a DEV environment */

# Terraform Config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.3.0"

  # TODO: Add remote state
}

# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

/* VPC */
resource "aws_vpc" "vpc" {
  # Set the CIDR block (the address space) for the VPC
  cidr_block           = var.vpc_cidr_block
  # Allow DNS hostnames to be created in the VPC (i.e. allow instances to have hostnames)
  enable_dns_hostnames = true
  tags                 = {
    deployment_id = random_string.deploy_id.result
    project       = var.app.name
    Name          = join("-", [var.app.name, "vpc"])
  }
}

/* Internet Gateway */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    deployment_id = random_string.deploy_id.result
    project       = var.app.name
    Name          = join("-", [var.app.name, "igw"])
  }
}

/* Public Subnets for hosting the Lambda function */
resource "aws_subnet" "public" {
  count = var.subnet_count.public
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    deployment_id = random_string.deploy_id.result
    project       = var.app.name
    Name          = join("-", [var.app.name, "public", count.index])
  }
}

/* Private Subnets for hosting the RDS instance */
resource "aws_subnet" "private" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = {
    deployment_id = random_string.deploy_id.result
    project       = var.app.name
    Name          = join("-", [var.app.name, "private-subnet", count.index])
  }
}

/* Routing Table */
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  # Declare a route for the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    deployment_id = random_string.deploy_id.result
    project       = var.app.name
    Name          = join("-", [var.app.name, "rt"])
  }
}

/* Public Subnet Association */
resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.rt.id
}

/* Private Subnet Association */
resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.rt.id
}

/* Our deployed Service */
module "service" {
  source = "../modules/service"

  aws_region = var.aws_region
  deploy_id  = random_string.deploy_id.result
  app = {
    name = "compliance"
    stage = "dev"
    version = "0.0.17"
    # static_url = "compliance-static-assets.s3.amazonaws.com"
    # These two values should be referenced from the result of the build pipeline
    ecr_url = "288251279596.dkr.ecr.us-east-2.amazonaws.com/compliance-ecr"
  }

  vpc_config = {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.vpc_cidr_block
  }

  subnets_config = {
    public_subnets = aws_subnet.public.*.id
    private_subnets = aws_subnet.private.*.id
  }

  # Default RDS is fine for Dev
}