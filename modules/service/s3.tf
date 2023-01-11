/* s3.tf: provisions a public s3 buckets for the cert files uploaded by admin users*/

/* Buckets */

# Cert bucket
resource "aws_s3_bucket" "cert" {
  bucket = join("-", [var.app.name, var.app.stage, "cert", var.deploy_id])
  tags   = {
    deploy_id = var.deploy_id
    project   = var.app.name
    stage     = var.app.stage
    Name      = join("-", [var.app.name, "cert-bucket"])
  }
}

/* Bucket ACLs */

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