/* Create S3 bucket for Static Django Assets */
resource "aws_s3_bucket" "static_assets_bucket" {
  bucket = join("-", ["static-asset-bucket", var.app_name])
  tags = {
    Name = join("-", ["static-asset-bucket", var.app_name])
  }
}