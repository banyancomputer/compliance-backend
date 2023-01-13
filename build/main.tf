# Terraform Config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.3.0"

  backend "s3" {
    bucket = "banyan-tf-remote-state"
    key    = "compliance/ecr/terraform.tfstate"
    region = "us-east-2"
  }
}
# Provider Configuration
provider "aws" {
  region = var.aws_region
}

