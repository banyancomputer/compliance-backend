/* TODO: Add support for a custom domain name */

/* API Gateway containing access to API resources */
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = join("-", [var.app.name, "api-gateway", var.deploy_id])
  description = "Serverless application for our Compliance API"
}

/* API deployment */
resource "aws_api_gateway_deployment" "api_gateway" {
  depends_on = [
    aws_api_gateway_integration.api,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = var.app.stage
}

/* All requests to the API gateway need to match a configured resource ini order to be handled */

/* Proxy resource for the API Gateway. Interfaces with Lambda */
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "api"
}

/* All methods need to route to a method */

/* Method for the proxy resource. Matches any path, auth, and handler */
resource "aws_api_gateway_method" "api" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "ANY"
  authorization = "NONE"
}

/* Each method needs to be integrated with a Lambda function */

/* Integration for the api method */
resource "aws_api_gateway_integration" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.api.resource_id
  http_method = aws_api_gateway_method.api.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}