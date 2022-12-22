variable "app_name" {
  description = "The name of the project we're hosting images for"
  type = string
}

variable "app_version" {
  description = "The overarching version of the project we're building"
  type = string
}

variable "aws_region" {
  description = "What region we want to host our assets in"
  type = string
}

variable "docker_path" {
    description = "The path to the directory containing the Dockerfile (relative to the playbook root)"
    type = string
}

variable "playbook_path" {
  description = "The path to the ansible playbook we want to use to build and push our Image"
  type = string
}

