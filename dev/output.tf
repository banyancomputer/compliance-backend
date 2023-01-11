output "deploy_id" {
    description = "The ID of the deployment"
    value = random_string.deploy_id.result
    depends_on = [random_string.deploy_id]
}
# The password for the database
output "rds_password" {
    description = "The password for the RDS instance"
    value = var.rds_password
    sensitive = true
}
# The ednpoint for the ec2 instance
output "ec2_endpoint" {
    description = "The endpoint for the EC2 instance"
    value = module.service.ec2_endpoint
}
# The private key for the ec2 instance
output "ec2_private_key" {
    description = "The private key for the EC2 instance"
    value = module.service.ec2_private_key
    sensitive = true
}
