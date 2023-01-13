/* Deployment and Service environment configuration */

/* AWS specific configuration */

# AWS region
variable "aws_region" {
  default = "us-east-2"
}

/* Service configuration */

# What to call resources created by this module
variable "service_name" {
  description = "Name of the application and associated resources"
  default = "compliance"
}

# What stage this service is in
variable "service_stage" {
  description = "Stage of the application and associated resources"
  default = "dev"
}

variable "service_domain_name" {
  description = "The primary domain name for the application and associated resources."
  default = "testing.banyan.computer"
}

/* Application and environment configuration */

# Where and what image to use for the application. See the output of the 'build' module for configuration.

variable "ecr_url" {
    description = "The URL of the ECR repository"
    default = "288251279596.dkr.ecr.us-east-2.amazonaws.com/compliance-django-ecr"
}

variable "app_version" {
  description = "Version of the application, as tagged in ECR"
  default = "0.0.0"
}

# Django configuration

variable "django_debug" {
  description = "Whether to run Django in debug mode. 0 or 1"
  default = "1"
}

variable "django_allowed_hosts" {
  description = "A list of hosts that are allowed to access the application, as a space-separated string"
  default = "*"
}

variable "django_sql_engine" {
  description = "The database engine to use for Django"
  default = "django.db.backends.postgresql"
}

variable "django_superuser_username" {
  description = "The username of the Django superuser"
  default = "admin"
}

variable "django_superuser_email" {
  description = "The email address of the Django superuser"
  default     = "alex@banyan.computer"
}

variable "django_use_s3" {
  description = "Whether to use S3 for storing uploaded files. TRUE or FALSE"
  default = "TRUE"
}