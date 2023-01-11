# Our AWS region
variable "aws_region" {
  description = "AWS region"
}
# A random string to append to the end of the name
variable "deploy_id" {
  description = "What deployment ID to attach to this service and its infrastructure"
}
# App staging, versioning, and image configuration
variable "app" {
  type        = map(string)
  description = "App staging, versioning, and image configuration"
  default     = {
    name    = "app" # What we call this app
    stage   = "dev" # What stage we're deploying to
    version = "0.0.0" # The version of the application to use in the service Ec2
    ecr_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com" # The URL to the ECR repository for our app image
  }
}
# Our VPC CIDR
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
# Our public subnet CIDRs
variable "public_subnet_cidr" {
  description = "A list of available public subnet CIDRs"
  type        = string
  default     = "10.0.1.0/24"
}
# Our private subnet CIDRs
variable "private_subnet_cidrs" {
  description = "A list of available private subnet CIDRs"
  type        = list(string)
  default     = [
    "10.0.101.0/24",
    "10.0.102.0/24",
  ]
}
# The environment for our Django app
variable "django_env" {
  description = "The environment for our Django app"
  type        = map(string)
  default     = {
    secret_key    = "secret_key"
    debug         = "1"
    allowed_hosts = "*"
    sql_engine    = "django.db.backends.postgresql"
    superuser_username = "admin"
    superuser_password = "admin"
    superuser_email = "alex@banyan.computer"
    use_s3 = "TRUE"
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
    engine              = "postgres"
    engine_version      = "14"
    db_name             = "compliance"
    skip_final_snapshot = "true"
  }
}
# The configuration for our EC2 instance
variable "ec2_config" {
  description = "Service Configuration for EC2"
  type        = map(any)
  # Set config values as strings and convert to the appropriate type.
  default     = {
    instance_type    = "t3.micro"
    monitoring       = "true"
    volume_type      = "gp2"
    volume_size      = "20" # in GB. The Size needed for the AMI
    ansible_playbook = "./ansible/ec2-setup.yml"
  }
}
# The user for our RDS database
variable "rds_user" {
  description = "The user for our RDS database"
  type        = string
  default     = "compliance"
}
# The key for our RDS database
variable "rds_password" {
  description = "The key for our RDS database"
  type        = string
}
