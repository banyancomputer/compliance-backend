output "api_endpoint" {
  value = aws_api_gateway_deployment.api_gateway.invoke_url
}

output "api_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
}

output "api_arn" {
  value = aws_api_gateway_rest_api.api_gateway.arn
}