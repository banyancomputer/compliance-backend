/* API Gateway containing access to API resources */
resource "aws_api_gateway_rest_api" "api_gateway" {
  name               = join("-", [var.app.name, var.app.stage, "api-gateway", var.deploy_id])
  description        = "Filecoin Compliance API Gateway"
  binary_media_types = ["*/*"]
}

/* API deployment */
resource "aws_api_gateway_deployment" "api_gateway" {
  depends_on = [
    aws_api_gateway_integration.lambda_api,
    aws_api_gateway_integration.s3_document,
  ]

  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = var.app.stage
}

/* All requests to the API gateway need to match a configured resource ini order to be handled */

/* API Gateway resource for our V0 API */

resource "aws_api_gateway_resource" "v0" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "v0"
}

/* V0 Resources: */

/* API Gateway resource for our V0 api */

// We just need one resource for the entire API. The api function will handle the routing.
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v0.id
  path_part   = "api"
}

/* API Gateway resource for our V0 certification buckets */

// We need a parent resource for our certification bucket
resource "aws_api_gateway_resource" "cert" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v0.id
  path_part   = "cert"
}

// We route the request to the certification bucket and serve the document
resource "aws_api_gateway_resource" "document" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.cert.id
  path_part   = "{document}"
}

/* All methods need to route to a method */

// We need a method for the api resource
resource "aws_api_gateway_method" "api" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "POST"
  authorization = "NONE"
}

// We need a method for the S3 bucket resource
resource "aws_api_gateway_method" "document" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.document.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.document" = true
  }
}

/* Each method needs to be integrated with some service or invocation */

// We need an integration for the api resource. This integration will invoke the lambda function
resource "aws_api_gateway_integration" "lambda_api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.api.resource_id
  http_method = aws_api_gateway_method.api.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}


// We need an integration for the cert resource. This will serve the contents of the S3 bucket holding the certs
resource "aws_api_gateway_integration" "s3_document" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method

  /* Set the path override to the {s3_bucket_name} / document name */

  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.s3.id}/{object}"

  request_parameters = {
    "integration.request.path.object" = "method.request.querystring.document"
  }

  credentials = aws_iam_role.s3-role.arn
}

/* We need method responses for each method so our API Gateway knows what to return to the client */

// We need method responses for the api method

// 200 response
resource "aws_api_gateway_method_response" "api_response_200" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
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
resource "aws_api_gateway_method_response" "api_response_400" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  status_code = "400"
}

// 500 response
resource "aws_api_gateway_method_response" "api_response_500" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  status_code = "500"
}

// We need method responses for the cert bucket method

// 200 response
resource "aws_api_gateway_method_response" "document_response_200" {
  depends_on = [aws_api_gateway_integration.s3_document]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method
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
resource "aws_api_gateway_method_response" "document_response_400" {
  depends_on = [aws_api_gateway_integration.s3_document]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method
  status_code = "400"
}

// 500 response
resource "aws_api_gateway_method_response" "document_response_500" {
  depends_on = [aws_api_gateway_integration.s3_document]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method
  status_code = "500"
}

/* We need to define the response models for each integration response from our underlying services */

// We need integration responses for the api integration

// 200 response
resource "aws_api_gateway_integration_response" "api_response_200" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  status_code = aws_api_gateway_method_response.api_response_200.status_code

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
resource "aws_api_gateway_integration_response" "api_response_400" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  status_code = aws_api_gateway_method_response.api_response_400.status_code

  selection_pattern = "4\\d{2}"
}

// 500 response
resource "aws_api_gateway_integration_response" "api_response_500" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.api.http_method
  status_code = aws_api_gateway_method_response.api_response_500.status_code

  selection_pattern = "5\\d{2}"
}

// We need integration responses for the cert bucket integration

// 200 response
resource "aws_api_gateway_integration_response" "document_response_200" {
  depends_on = [aws_api_gateway_integration.s3_document]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method
  status_code = aws_api_gateway_method_response.document_response_200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}

// 400 response
resource "aws_api_gateway_integration_response" "document_response_400" {
  depends_on = [aws_api_gateway_integration.s3_document]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method
  status_code = aws_api_gateway_method_response.document_response_400.status_code

  selection_pattern = "4\\d{2}"
}

// 500 response
resource "aws_api_gateway_integration_response" "document_response_500" {
  depends_on = [aws_api_gateway_integration.s3_document]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.document.id
  http_method = aws_api_gateway_method.document.http_method
  status_code = aws_api_gateway_method_response.document_response_500.status_code

  selection_pattern = "5\\d{2}"
}
