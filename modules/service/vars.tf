/* AWS and Deploy Config */

# AWS region
variable "aws_region" {
  description = "AWS region"
}
# A string describing what service this is for
variable "name" {
  description = "app"
}
# A string describing what stage this is for
variable "stage" {
  description = "dev"
}
# A random string to append to the end of the name
variable "deploy_id" {
  description = "What deployment ID to attach to this service and its infrastructure. Should be lowercase and alphanumeric"
}
# The Root Domain Name of the service
variable "domain_name" {
  description = "The primary domain name of the service. This will be used to create the Route53 zone and the ACM certificate."
}

/* Ec2 Configuration */

# The configuration for our EC2 instance
variable "ec2_config" {
  description = "Service Configuration for EC2"
  type        = map(any)
  # Set config values as strings and convert to the appropriate type.
  default     = {
    instance_type    = "t3.micro" # The instance type to use for the EC2 instance
    monitoring       = "true" # Whether to enable detailed monitoring
    volume_type      = "gp2" # The type of volume to use for the EC2 instance
    volume_size      = "20" # in GB. How big of a volume to mount on the Ec2. This is the Size needed for the AMI
  }
}

/* RDS Configuration */

# The settings for our RDS database
variable "rds_config" {
  description = "Service Configuration for RDS"
  type        = map(any)
  # Set config values as strings and convert to the appropriate type.
  default     = {
    allocated_storage   = "5" # in GB. How much storage to allocate for the database
    instance_class      = "db.t3.micro" # The instance class to use
    engine              = "postgres" # The database engine to use
    engine_version      = "14" # The version of the database engine to use
    db_name             = "serviceDB" # The name of the database to create
    skip_final_snapshot = "true" # Whether to skip creating a final snapshot before the database is deleted
  }
}
# The user for our RDS database
variable "rds_username" {
  description = "The user for our RDS database"
  type        = string
}
# The key for our RDS database
variable "rds_password" {
  description = "The key for our RDS database"
  type        = string
}

/* VPC Configuration. We need one public subnet and two private */

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
