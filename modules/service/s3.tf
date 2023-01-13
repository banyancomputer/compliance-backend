/* s3.tf: provisions a public s3 buckets for the cert files uploaded by admin users*/

/* Buckets */

# Cert bucket
resource "aws_s3_bucket" "cert" {
  bucket        = join("-", [var.name, "cert-bucket", var.stage, var.deploy_id])
  # Destroy this bucket when destroying the stack if this isn't a production stack
  force_destroy = var.stage != "prod"
  tags          = {
    deploy_id    = var.deploy_id
    service_name = var.name
    stage        = var.stage
    name         = join("-", [var.name, "cert-bucket"])
  }
}

/* Bucket Policy */

# Cert bucket is publicly readable
resource "aws_s3_bucket_policy" "cert" {
  bucket = aws_s3_bucket.cert.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadForGetBucketObjects",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.cert.id}/*"
        }
      ]
    })
}