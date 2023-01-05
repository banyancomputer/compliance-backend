/* lambda.tf: deploy a lambda function to host our Django service */

# Lambda function
#resource "aws_lambda_function" "lambda" {
#  # Function name
#  function_name = join("-", [var.app.name, var.app.stage, "lambda", var.deploy_id])
#  # Pull the latest version of the lambda function from ECR
#  image_uri     = "${var.app.ecr_url}:${var.app.version}"
#  # This is an image based lambda function
#  package_type  = "Image"
#  # Set the role for the lambda function
#  role          = aws_iam_role.lambda_role.arn
#  # Register the lambda function inside the VPC
#  vpc_config {
#    subnet_ids         = var.subnets_config.public_subnets
#    security_group_ids = [aws_security_group.rds.id]
#  }
#  # Set the environment variables
#  environment {
#    variables = {
#      # For connecting to the RDS instance
#      DB_HOST     = split(":", aws_db_instance.rds.address)[0]
#      DB_NAME     = var.rds_config.db_name
#      DB_USER     = aws_db_instance.rds.username
#      DB_PASS     = aws_db_instance.rds.password
#    }
#  }
#
#  tags = {
#    deploy_id = var.deploy_id
#    project   = var.app.name
#    stage     = var.app.stage
#    name      = join("-", [var.app.name, var.app.stage, "lambda", var.deploy_id])
#  }
#}
#
## IAM policy for interacting with the RDS instance
#resource "aws_iam_policy" "lambda_policy" {
#  name = join("-", [
#    var.app.name, var.app.stage, "lambda", var.deploy_id
#  ])
#  description = "Policy for lambda to interact with RDS"
#  policy      = jsonencode({
#    Version   = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Action = [
#          "ec2:CreateNetworkInterface",
#          "ec2:DescribeNetworkInterfaces",
#          "ec2:DeleteNetworkInterface",
#        ]
#        Resource = "*"
#      },
#    ]
#  })
#}
#
## IAM role for assuming the role of a lambda function
#resource "aws_iam_role" "lambda_role" {
#  name = join("-", [
#    var.app.name, var.app.stage, "lambda-role", var.deploy_id
#  ])
#  # "I can execute Lambda functions" role policy
#  assume_role_policy = jsonencode({
#    Version   = "2012-10-17"
#    Statement = [
#      {
#        Action = [
#          "sts:AssumeRole",
#        ]
#        Effect    = "Allow"
#        Principal = {
#          Service = "lambda.amazonaws.com"
#        }
#      }
#    ]
#  })
#  tags = {
#    deploy_id = var.deploy_id
#    project   = var.app.name
#    stage     = var.app.stage
#    name      = join("-", [var.app.name, var.app.stage, "lambda-role", var.deploy_id])
#  }
#}
#
## Attach the policy to the role
#resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#  role       = aws_iam_role.lambda_role.name
#  policy_arn = aws_iam_policy.lambda_policy.arn
#}
#
## Lambda permission for the API gateway
#resource "aws_lambda_permission" "api-gateway" {
#  statement_id  = "AllowAPIGatewayInvoke"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.lambda.function_name
#  principal     = "apigateway.amazonaws.com"
#
#  # The /*/* portion grants access from any method on any resource
#  # within the API Gateway "REST API".
#  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
#}