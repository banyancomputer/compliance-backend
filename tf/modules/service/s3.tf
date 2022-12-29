/* Create a private bucket that can only be accessed through the API gateway */
resource "aws_s3_bucket" "s3" {
  bucket = join("-", [var.app.name, var.app.stage, "s3", var.deploy_id])
  tags   = {
    deploy_id = var.deploy_id
    project   = var.app.name
    stage     = var.app.stage
    name      = join("-", [var.app.name, var.app.stage, "s3", var.deploy_id])
  }
}

# Create S3 Full Access Policy - TODO: Restrict to read only
resource "aws_iam_policy" "s3-policy" {
  name        = join("-", [var.app.name, var.app.stage, "s3-policy", var.deploy_id])
  description = "Policy for allowing all S3 Actions"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:Get*",
          "s3:List*"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = {
    deploy_id = var.deploy_id
    project   = var.app.name
    stage     = var.app.stage
    name      = join("-", [var.app.name, var.app.stage, "s3-policy", var.deploy_id])
  }
}

/* IAM Role for reading from S3 */
resource "aws_iam_role" "s3-role" {
  name               = join("-", [var.app.name, var.app.stage, "s3-role", var.deploy_id])
  # "I can assume S3 ownership from the API Gateway" role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    deploy_id = var.deploy_id
    project   = var.app.name
    stage     = var.app.stage
    name      = join("-", [var.app.name, var.app.stage, "s3-role", var.deploy_id])
  }
}

/* Attach the S3 Access Policy to the S3 Role */
resource "aws_iam_role_policy_attachment" "s3-role-policy-attachment" {
  role       = aws_iam_role.s3-role.name
  policy_arn = aws_iam_policy.s3-policy.arn
}