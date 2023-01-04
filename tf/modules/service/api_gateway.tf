/* api_gateway.tf: Expose our Lambda and S3 resources through a single API */

# API Gateway containing access to API resources
resource "aws_api_gateway_rest_api" "api_gateway" {
  name               = join("-", [var.app.name, var.app.stage, "api-gateway", var.deploy_id])
  description        = "Filecoin Compliance API Gateway"
  binary_media_types = ["*/*"]
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "api_gateway" {
  depends_on = [
    aws_api_gateway_integration.lambda_api,
    aws_api_gateway_integration.s3_cert,
  ]

  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = var.app.stage
}

/* All requests to the API gateway need to match a path to a
 * -> resource
 * -> method
 * -> integration
 * in order to be handled by the gateway */

/* V0 API */

# V0 top-level resource
resource "aws_api_gateway_resource" "v0" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "v0"
}

/* V0 Resources */

# 'API' resources: integrates with our django Lambdas
# 'API' top-level resource. This is the top-level resource for requests to our lambda proxy
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v0.id
  path_part   = "api"
}
# `API Proxy` resource. This is the resource for requests to our lambda
resource "aws_api_gateway_resource" "api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "{proxy+}"
}

# 'CERT' resource: serves files from S3 bucket
# We need a parent resource for our certification bucket
resource "aws_api_gateway_resource" "cert" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.v0.id
  path_part   = "cert"
}

/* V0 Methods */

# `API Proxy` method. This defines a method to route requests to our lambda
resource "aws_api_gateway_method" "api_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}
# `CERT` method. This defines a method to route requests to our S3 bucket
resource "aws_api_gateway_method" "cert" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.cert.id
  http_method   = "GET"
  authorization = "NONE"

  # Requests to specific paths in the S3 bucket should be formatted in query params
  request_parameters = {
    "method.request.querystring.doc" = true
  }
}

/* V0 Integrations */

# `API Proxy` integration. This connects our API method to our Lambda
resource "aws_api_gateway_integration" "lambda_api" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_method.api_proxy.resource_id
  http_method = aws_api_gateway_method.api_proxy.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "ANY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}
# `CERT` integration. This connects our CERT method to our S3 bucket
resource "aws_api_gateway_integration" "s3_cert" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method

  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.s3.id}/{object}"

  # Integration requests to the S3 bucket should be formatted in query params
  request_parameters = {
    "integration.request.path.object" = "method.request.querystring.doc"
  }

  # This integration has access to the S3 bucket
  credentials = aws_iam_role.s3-role.arn
}

/* V0 Method Responses */

# API 200 response
resource "aws_api_gateway_method_response" "api_response_200" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method
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
# API 400 response
resource "aws_api_gateway_method_response" "api_response_400" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method
  status_code = "400"
}
# API 500 response
resource "aws_api_gateway_method_response" "api_response_500" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method
  status_code = "500"
}
# CERT 200 response
resource "aws_api_gateway_method_response" "cert_response_200" {
  depends_on = [aws_api_gateway_integration.s3_cert]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method
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
# CERT 400 response
resource "aws_api_gateway_method_response" "cert_response_400" {
  depends_on = [aws_api_gateway_integration.s3_cert]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method
  status_code = "400"
}
# CERT 500 response
resource "aws_api_gateway_method_response" "cert_response_500" {
  depends_on = [aws_api_gateway_integration.s3_cert]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method
  status_code = "500"
}

/* V0 Integration Responses */
# API 200 response
resource "aws_api_gateway_integration_response" "api_response_200" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method
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
# API 400 response
resource "aws_api_gateway_integration_response" "api_response_400" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method
  status_code = aws_api_gateway_method_response.api_response_400.status_code

  selection_pattern = "4\\d{2}"
}
# API 500 response
resource "aws_api_gateway_integration_response" "api_response_500" {
  depends_on = [aws_api_gateway_integration.lambda_api]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method
  status_code = aws_api_gateway_method_response.api_response_500.status_code

  selection_pattern = "5\\d{2}"
}
# CERT 200 response
resource "aws_api_gateway_integration_response" "cert_response_200" {
  depends_on = [aws_api_gateway_integration.s3_cert]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method
  status_code = aws_api_gateway_method_response.cert_response_200.status_code

  response_parameters = {
    "method.response.header.Timestamp"      = "integration.response.header.Date"
    "method.response.header.Content-Length" = "integration.response.header.Content-Length"
    "method.response.header.Content-Type"   = "integration.response.header.Content-Type"
  }
}
# CERT 400 response
resource "aws_api_gateway_integration_response" "cert_response_400" {
  depends_on = [aws_api_gateway_integration.s3_cert]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method
  status_code = aws_api_gateway_method_response.cert_response_400.status_code

  selection_pattern = "4\\d{2}"
}
# CERT 500 response
resource "aws_api_gateway_integration_response" "cert_response_500" {
  depends_on = [aws_api_gateway_integration.s3_cert]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cert.id
  http_method = aws_api_gateway_method.cert.http_method
  status_code = aws_api_gateway_method_response.cert_response_500.status_code

  selection_pattern = "5\\d{2}"
}


