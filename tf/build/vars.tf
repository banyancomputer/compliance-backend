variable "aws_region" {
  default = "us-east-2"
}

variable "app_name" {
  description = "The name of the project we're hosting images for"
  type = string
  default = "compliance"
}

variable "app_version" {
  description = "The overarching version of the project we're building. Set this when building a new version of the project."
  type = string
}