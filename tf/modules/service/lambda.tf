/* Backend Lambda for reading and writing to RDS */
resource "aws_lambda_function" "lambda" {
    # Dynamically generated name
    function_name = join("-", [var.app.name, "lambda", var.deploy_id])
    # Pull the latest version of the lambda function from ECR
    image_uri = "${var.app.ecr_url}:${var.app.version}"
    package_type = "Image"
    # SEt the role for the lambda function
    role = aws_iam_role.lambda_exec.arn

#    environment {
#        variables = {
#            # TODO: Set the environment variables for the lambda function
#            # Database connection goes here
#            # Static asset bucket goes here
#        }
#    }

    tags = {
        deploy_id = var.deploy_id
        project = var.app.name
        Name = join("-", [var.app.name, "lambda", var.deploy_id])
    }
}

/* IAM Role for executing Lambda */
resource "aws_iam_role" "lambda_exec" {
    name = join("-", [var.app.name, "lambda-exec-role", var.deploy_id])
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
        deployment_id = var.deploy_id
        project = var.app.name
        name = join("-", [var.app.name, "lambda-exec-role", var.deploy_id])
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
    source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}