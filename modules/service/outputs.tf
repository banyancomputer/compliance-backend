# Endpoint for the Ec2 instance
output "ec2_endpoint" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_eip.ec2.public_dns
  depends_on  = [aws_eip.ec2]
}
# Private Key for the EC2 instance
output "ec2_private_key" {
  description = "The private key of the EC2 instance"
  value       = tls_private_key.ec2.private_key_pem
  depends_on  = [tls_private_key.ec2]
  sensitive   = true
}
output "ec2_ssh_exec" {
  description = "The ssh command to connect to the EC2 instance"
  value       = "ssh -i ${tls_private_key.ec2.private_key_pem} ec2-user@${aws_eip.ec2.public_dns}"
  depends_on  = [tls_private_key.ec2, aws_eip.ec2]
}