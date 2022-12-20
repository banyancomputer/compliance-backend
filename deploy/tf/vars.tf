# Our AWS region
variable "aws_region" {
  default = "us-east-2"
}
# A random string to append to the end of the name
resource "random_string" "deploy_id" {
  length  = 8
  upper   = false
  special = false
}
# What defines access to our application
variable "app" {
  type    = map(string)
  default = {
    name         = "compliance" # The name of the application
    stage        = "dev" # The stage of the application
    version      = "0.0.6" # The version of the application
    api_hostname = "testing.banyan.computer" # The lowest level hostname for the application
  }
}
# The settings for our Instances
variable "settings" {
  description = "Configuration Settings"
  type        = map(map(string))
  # Note (al): For some reason, map(map(any)) doesn't work here.
  # Set config values as strings and convert to the appropriate type.
  default     = {
    # Configuration for RDS
    rds = {
      allocated_storage   = "5" # in GB TODO: Make this a variable/bigger
      engine              = "postgres"
      engine_version      = "14"
      instance_class      = "db.t3.micro" # TODO: Upgrade for production
      db_name             = "compliance-db"
      skip_final_snapshot = "true" # Don't create a final snapshot (backup). TODO: change for production
    },
    # Configuration for S3 (Might need multiple buckets)
#    s3 = {
#      bucket_name = var.app.name + "-bucket"
#      # ...
#    },
  }
}
# Our VPC CIDR
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
# Our public subnet counts
variable "subnet_count" {
  description = "A mapping for the number of subnets for each type"
  type        = map(number)
  default     = {
    public  = 1 # One public for our API gateway
    private = 2 # Two private for our RDS instance
  }
}
# Our public subnet CIDRs
variable "public_subnet_cidrs" {
  description = "A list of available public subnet CIDRs"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}
# Our private subnet CIDRs
variable "private_subnet_cidrs" {
  description = "A list of available private subnet CIDRs"
  type        = list(string)
  default     = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}
# The username for our RDS instance
variable "rds_username" {
  description = "The username for our RDS instance"
  type        = string
  sensitive   = true
}
# The password for our RDS instance
variable "rds_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}