/* vpc.tf: Configuration for the VPC and networking infrastructure our service needs */

# Who's the owner of this infrastructure?
data "aws_caller_identity" "current" {}

# Available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  # Set the CIDR block (the address space) for the VPC
  cidr_block           = var.vpc_cidr_block
  # Allow DNS hostnames to be created in the VPC (i.e. allow instances to have hostnames)
  enable_dns_hostnames = true
  tags                 = {
    deploy_id = var.deploy_id
    service_name = var.name
    stage = var.stage
    name = join("-", [var.name, "vpc"])
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    deploy_id = var.deploy_id
    service_name = var.name
    stage = var.stage
    name = join("-", [var.name, "igw"])
  }
}

# Public Subnet for the Ec2 instance
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    deploy_id = var.deploy_id
    service_name = var.name
    stage = var.stage
    name = join("-", [var.name, "public-subnet"])
  }
}

# Private Subnets for the RDS instance
resource "aws_subnet" "private" {
  # RDS requires two private subnets
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = {
    deploy_id = var.deploy_id
    service_name = var.name
    stage = var.stage
    name = join("-", [var.name, "private-subnet", count.index])
  }
}

# Routing table for the VPC
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  # Declare a route for the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    deploy_id = var.deploy_id
    service_name = var.name
    stage = var.stage
    name = join("-", [var.name, "rt"])
  }
}

# Public subnet association with the routing table for our EC2 instance
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# Private subnet association with the routing table for our RDS instance
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.rt.id
}