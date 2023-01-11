# Our ECR url
output "ecr_url" {
  value = aws_ecr_repository.ecr.repository_url
}
# The latest version of the app
output "latest_image_version" {
  value = var.app_version
}