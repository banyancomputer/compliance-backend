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
# Call our build module
module "build" {
  source = "../modules/build"
  app_name = "compliance"
  app_version = "0.0.0"
  aws_region = var.aws_region
  docker_path = "../docker"
  playbook_path = "./ansible/image-build.yml"
}

