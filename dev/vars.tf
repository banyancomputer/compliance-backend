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
    name         = "compliance-django" # The name of the application
    stage        = "dev" # The stage of the application
    version      = "0.0.1" # The version of the application
  }
}