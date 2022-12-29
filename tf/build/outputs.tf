# Our ECR url
output "ecr_url" {
  value = aws_ecr_repository.ecr.repository_url
}