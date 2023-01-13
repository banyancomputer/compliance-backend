/* ELB outputs */

output "elb_dns_name" {
  description = "DNS name of the ELB"
  value = aws_elb.elb.dns_name
}
output "elb_https_endpoint" {
  description = "HTTPS endpoint of the ELB"
  value = "https://${var.stage == "prod" ? "" : var.stage}${var.stage == "prod" ? "" : "."}${var.domain_name}"
}

/* Ec2 Outputs */

# Endpoint for the Ec2 instance
output "ec2_endpoint" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_eip.ec2.public_dns
  depends_on  = [aws_eip.ec2]
}
# Private Key for the EC2 instance. This is also saved to the local file system
output "ec2_private_key" {
  description = "The private key of the EC2 instance"
  value       = tls_private_key.ec2.private_key_pem
  depends_on  = [tls_private_key.ec2]
  sensitive   = true
}
output "ec2_ssh_exec" {
  description = "The ssh command to connect to the EC2 instance on the local machine"
  value       = "ssh -i ${tls_private_key.ec2.private_key_pem} ec2-user@${aws_eip.ec2.public_dns}"
  depends_on  = [tls_private_key.ec2, aws_eip.ec2]
}
output "ec2_priv_key_path" {
  description = "The path to the private key of the EC2 instance on the local machine"
  value       = null_resource.ec2-key-write.triggers.key_file_path
  depends_on = [tls_private_key.ec2]
}

/* RDS Outputs */

# Endpoint for the RDS instance
output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.rds.endpoint
  depends_on  = [aws_db_instance.rds]
}
output "rds_username" {
  description = "The username of the RDS instance"
  value       = aws_db_instance.rds.username
  depends_on  = [aws_db_instance.rds]
}
output "rds_engine" {
  description = "The engine of the RDS instance"
  value       = aws_db_instance.rds.engine
  depends_on  = [aws_db_instance.rds]
}
output "rds_db_name" {
    description = "The name of the RDS database"
    value       = aws_db_instance.rds.db_name
  depends_on  = [aws_db_instance.rds]
}
/* S3 Outputs */
output "cert_bucket_name" {
  value = aws_s3_bucket.cert.id
}

