# Our deployment Id
output "deploy_id" {
    description = "The ID of the deployment"
    value = random_string.deploy_id.result
    depends_on = [random_string.deploy_id]
}
# The public DNS endpoint of our Ec2 instance
output "ec2_endpoint" {
    description = "The endpoint for the EC2 instance"
    value = module.service.ec2_endpoint
}
# Path to the key you can use to SSH into the EC2 instance
output "ec2_priv_key_path" {
    description = "The path to the private key for the EC2 instance on the local machine"
    value = module.service.ec2_priv_key_path
}
output "elb_dns_name" {
    description = "The DNS name of the ELB"
    value = module.service.elb_dns_name
}
# The public DNS name of our ELB
output "elb_endpoint" {
    description = "The endpoint for the ELB"
    value = module.service.elb_https_endpoint
}
output "rds_username" {
    description = "The username for the RDS instance"
    value = "admin"
}
# The password for the database
output "rds_password" {
    description = "The password for the RDS instance"
    value = random_string.rds_password.result
    sensitive = true
}
# The password for the django admin user
output "django_superuser_password" {
    description = "The password for the django admin user"
    value = random_string.django_superuser_password.result
    sensitive = true
}
