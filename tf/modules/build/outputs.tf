# Where our ECR repo lives
output "ecr_url" {
  value = aws_ecr_repository.ecr.repository_url
}

# Where our Static assets live
output "s3-bucket" {
  value = aws_s3_bucket.static_assets_bucket.bucket
}