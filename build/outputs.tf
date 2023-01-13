# Our ECR url
output "ecr_url" {
  description = "ECR URL where tagged images can be found"
  value = "${aws_ecr_repository.ecr.repository_url}/${var.app_name}-ecr"
}
# The latest version of the app
output "latest_image_version" {
  description = "The version of the app most recently pushed to ECR"
  value = var.app_version
}