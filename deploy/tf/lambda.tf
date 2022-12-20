/* Backend Lambda for reading and writing to RDS */
resource "aws_lambda_function" "lambda" {
    # Dynamically generated name
    function_name = join("-", [var.app.name, "lambda", random_string.deploy_id.result])
    # Pull the latest version of the lambda function from ECR
    image_uri = "${aws_ecr_repository.ecr.repository_url}:${var.app.version}"
    package_type = "Image"
    # SEt the role for the lambda function
    role = aws_iam_role.lambda-exec.arn
    tags = {
        Name = join("-", [var.app.name, "rds-app", random_string.deploy_id.result])
    }
}

/* IAM Role for executing Lambda */
resource "aws_iam_role" "lambda-exec" {
    name = join("-", [var.app.name, "lambda-exec-role", random_string.deploy_id.result])
    # "I can execute Lambda functions" role policy
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
    tags = {
        deployment_id = random_string.deploy_id.result
        project = var.app.name
        name = join("-", [var.app.name, "lambda-exec-role", random_string.deploy_id.result])
    }
}

/* Lambda permission for the API gateway */
resource "aws_lambda_permission" "api-gateway" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal     = "apigateway.amazonaws.com"

    # The /*/* portion grants access from any method on any resource
    # within the API Gateway "REST API".
    source_arn = aws_api_gateway_rest_api.api-gateway.execution_arn
}