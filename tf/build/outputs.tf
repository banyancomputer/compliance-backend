# Our ECR url
output "ecr_url" {
  value = aws_ecr_repository.ecr.repository_url
}

# Deprecated until need for static assets is determined
# Our S3 bucket url
#output "s3_url" {
#  value = aws_s3_bucket.s3.bucket_domain_name
#}