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


/* Our deployed Service */
module "service" {
  source = "../modules/service"

  aws_region = var.aws_region
  deploy_id  = random_string.deploy_id.result
  app = {
    name = "compliance-django"
    stage = "dev"
    version = "0.0.3"
    ecr_url = "288251279596.dkr.ecr.us-east-2.amazonaws.com/compliance-django-ecr"
  }
  # Default VPC config is fine for now

  # Default RDS is fine for Dev

  # TODO - Remember to add ansible command for provisioning the ec2 instance

  rds_user = "compliance"
  rds_password = "changeme"
}