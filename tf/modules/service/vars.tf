# Our AWS region
variable "aws_region" {
  description = "AWS region"
}
# A random string to append to the end of the name
variable "deploy_id" {
  description = "What deployment ID to attach to this service"
}
# What defines access to our application
variable "app" {
  type    = map(string)
  default = {
    name = "app"
    stage = "dev"
    version      = "0.0.0" # The version of the application to service
    static_url   = "https://s3.amazonaws.com/your-bucket-name" # The URL to the static assets for our app
    ecr_url      = "123456789012.dkr.ecr.us-east-1.amazonaws.com" # The URL to the ECR repository for our app
  }
}
# The settings for our Instances
variable "rds_config" {
  description = "Service Configuration for RDS"
  type        = map(string)
  # Set config values as strings and convert to the appropriate type.
  default     = {
    allocated_storage   = "5"
    engine              = "postgres"
    engine_version      = "14"
    instance_class      = "db.t3.micro"
    db_name             = "compliance-db"
    skip_final_snapshot = "true"
  }
}

variable "lambda_config" {
  description = "Service Configuration for Lambda"
  type        = map(string)
  # Set config values as strings and convert to the appropriate type.
  default = {}
}

# The username for our RDS instance
#variable "rds_username" {
#  description = "The username for our RDS instance"
#  type        = string
#  # Treat this as a sensitive value!
#  sensitive   = true
#}
#
## The password for our RDS instance
#variable "rds_password" {
#  description = "The password for the RDS instance"
#  type        = string
#  # Treat this as a sensitive value!
#  sensitive   = true
#}