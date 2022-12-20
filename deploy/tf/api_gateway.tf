/* TODO: Add support for a custom domain name */

/* API Gateway containing access to API resources */
resource "aws_api_gateway_rest_api" "api-gateway" {
  name        = join("-", [var.app.name, "api", random_string.deploy_id.result])
  description = "Serverless function for serving RDS data"
}

/* API deployment */
resource "aws_api_gateway_deployment" "api-gateway" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  stage_name  = var.app.stage
}

/* All requests to the API gateway need to match a configured resource ini order to be handled */

/* Proxy resource for the API Gateway */
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "{proxy+}"
}

/* All methods need to route to a method */

/* Method for the proxy resource. Matches any path, auth, and handler */
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api-gateway.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

/* But proxy methods don't match root (empty) paths, so we need to add a catch-all method */
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.api-gateway.id
  resource_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

/* Each method needs to be integrated with a Lambda function */

/* Integration for the proxy method */
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

/* Integration for the proxy root method */
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}