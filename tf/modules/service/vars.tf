# Our AWS region
variable "aws_region" {
  description = "AWS region"
}
# A random string to append to the end of the name
variable "deploy_id" {
  description = "What deployment ID to attach to this service"
}
# App staging, versioning, and image configuration
variable "app" {
  type        = map(string)
  description = "App staging, versioning, and image configuration"
  default     = {
    name    = "app"
    stage   = "dev"
    version = "0.0.0" # The version of the application to service
    ecr_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com" # The URL to the ECR repository for our app
  }
}
# The configuration for the VPC we want to deploy into
variable "vpc_config" {
  description = "The VPC configuration for the application"
  type        = map(string)
  default     = {
    vpc_id     = ""
    cidr_block = ""
  }
}
# The configuration for the Subnets inside our VPC
variable "subnets_config" {
  description = "The subnets configuration for the application"
  type        = map(any)
  default     = {
    public_subnets  = []
    private_subnets = []
  }
}
# The settings for our RDS database
variable "rds_config" {
  description = "Service Configuration for RDS"
  type        = map(any)
  # Set config values as strings and convert to the appropriate type.
  default     = {
    allocated_storage   = "5"
    instance_class      = "db.t3.micro"
    skip_final_snapshot = "true"
    db_name             = "compliance"
  }
}
# The key for our RDS database
variable "rds_password" {
  description = "The key for our RDS database"
  sensitive   = true
  default     = "changeme"
}
