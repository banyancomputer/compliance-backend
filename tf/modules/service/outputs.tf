# Endpoint for the API
output "api_endpoint" {
  value = aws_api_gateway_deployment.api_gateway.invoke_url
}
# Endpoint for the Ec2 instance
output "ec2_endpoint" {
  description = "The public DNS name of the EC2 instance"
  value = aws_eip.ec2.public_dns
  depends_on = [aws_eip.ec2]
}
# Private Key for the EC2 instance
output "ec2_private_key" {
  description = "The private key of the EC2 instance"
  value = tls_private_key.ec2.private_key_pem
  depends_on = [tls_private_key.ec2]
  sensitive = true
}
