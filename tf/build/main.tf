# Terraform Config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.3.0"
}
# Provider Configuration
provider "aws" {
  region = var.aws_region
}

