/* API Gateway containing access to API resources */
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = join("-", [var.app.name, var.app.stage, "api-gateway", var.deploy_id])
  description = "Filecoin Compliance API Gateway"
}

/* API deployment */
resource "aws_api_gateway_deployment" "api_gateway" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.s3,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = var.app.stage
}

/* All requests to the API gateway need to match a configured resource ini order to be handled */

/* Resource for our Lambda */
resource "aws_api_gateway_resource" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "api"
}

/* Resources for our S3 bucket */

resource "aws_api_gateway_resource" "s3" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "s3"
}

resource "aws_api_gateway_resource" "s3-folder" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.s3.id
  path_part   = "{folder}"
}

resource "aws_api_gateway_resource" "s3-item" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.s3-folder.id
  path_part   = "{item}"
}

/* All methods need to route to a method */

/* Method for the lambda resource. */
resource "aws_api_gateway_method" "lambda" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.lambda.id
  http_method   = "ANY"
  authorization = "NONE"
}

/* Method for the S3 folder resource. */
resource "aws_api_gateway_method" "s3" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.s3.id
  http_method   = "GET"
  authorization = "NONE"
}

/* Each method needs to be integrated with a Lambda function */

/* Integration for the api methods */
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.lambda.resource_id
  http_method = aws_api_gateway_method.lambda.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}
#
#/* Integration for the S3 methods */
resource "aws_api_gateway_integration" "s3" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.s3.resource_id
  http_method = aws_api_gateway_method.s3.http_method

  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:s3:path//"

  credentials = aws_iam_role.s3-role.arn
}

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Timestamp"      = true
    "method.response.header.Content-Length" = true
    "method.response.header.Content-Type"   = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "method_response_400" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = "400"
}

resource "aws_api_gateway_method_response" "method_response_500" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

resource "aws_api_gateway_integration_response" "integration_response_400" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = aws_api_gateway_method_response.method_response_400.status_code

  selection_pattern = "4\\d{2}"
}

resource "aws_api_gateway_integration_response" "integration_response_500" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = aws_api_gateway_method_response.method_response_500.status_code

  selection_pattern = "5\\d{2}"
}
