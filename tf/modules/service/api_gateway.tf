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

// We just need one resource for the entire Lambda. It's handler should be able to handle all requests.
resource "aws_api_gateway_resource" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "api"
}

/* Resources for our S3 bucket */

// We need a root resource for the S3 bucket
resource "aws_api_gateway_resource" "s3" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "s3"
}

// We need a resource under the S3 bucket root resource for each folder we want to serve
resource "aws_api_gateway_resource" "s3_folder" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.s3.id
  path_part   = "{folder}"
}

// We need a resource under the S3 bucket folder resource for each file we want to serve
resource "aws_api_gateway_resource" "s3_item" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.s3_folder.id
  path_part   = "{item}"
}

/* All methods need to route to a method */

// We need a method for the lambda resource
resource "aws_api_gateway_method" "lambda" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.lambda.id
  http_method   = "ANY"
  authorization = "NONE"
}

// We need a method for the S3 bucket resource
resource "aws_api_gateway_method" "s3" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.s3.id
  http_method   = "GET"
  authorization = "NONE"
}

/* Each method needs to be integrated with some service or invocation */

// We need an integration for the lambda resource. This will invoke the lambda function
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.lambda.resource_id
  http_method = aws_api_gateway_method.lambda.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}


// We need an integration for the S3 bucket resource. This will serve the S3 bucket
resource "aws_api_gateway_integration" "s3" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
  http_method = aws_api_gateway_method.s3.http_method

  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:s3:path//"

  credentials = aws_iam_role.s3-role.arn
}

/* We need method responses for each method so our API Gateway knows what to return to the client */

// We need method responses for the lambda method

// 200 response
resource "aws_api_gateway_method_response" "lambda_response_200" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda.http_method
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

// 400 response
resource "aws_api_gateway_method_response" "lambda_response_400" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = "400"
}

// 500 response
resource "aws_api_gateway_method_response" "lambda_response_500" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = "500"
}

// We need method responses for the S3 bucket method

// 200 response
resource "aws_api_gateway_method_response" "s3_response_200" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
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

// 400 response
resource "aws_api_gateway_method_response" "s3_response_400" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = "400"
}

// 500 response
resource "aws_api_gateway_method_response" "s3_response_500" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = "500"
}

/* We need to define the response models for each integration response from our underlying services */

// We need integration responses for the lambda integration

// 200 response
resource "aws_api_gateway_integration_response" "lambda_response_200" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = aws_api_gateway_method_response.lambda_response_200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Timestamp"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }

  response_templates = {
    "application/json" = ""
  }
}

// 400 response
resource "aws_api_gateway_integration_response" "lambda_response_400" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = aws_api_gateway_method_response.lambda_response_400.status_code

  selection_pattern = "4\\d{2}"
}

// 500 response
resource "aws_api_gateway_integration_response" "lambda_response_500" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = aws_api_gateway_method_response.lambda_response_500.status_code

  selection_pattern = "5\\d{2}"
}

// We need integration responses for the S3 bucket integration

// 200 response
resource "aws_api_gateway_integration_response" "s3_response_200" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = aws_api_gateway_method_response.s3_response_200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

// 400 response
resource "aws_api_gateway_integration_response" "s3_response_400" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = aws_api_gateway_method_response.s3_response_400.status_code

  selection_pattern = "4\\d{2}"
}

// 500 response
resource "aws_api_gateway_integration_response" "s3_response_500" {
  depends_on = [aws_api_gateway_integration.s3]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.s3.id
  http_method = aws_api_gateway_method.s3.http_method
  status_code = aws_api_gateway_method_response.s3_response_500.status_code

  selection_pattern = "5\\d{2}"
}
