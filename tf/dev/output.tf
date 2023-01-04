output "deploy_id" {
    description = "The ID of the deployment"
    value = random_string.deploy_id.result
    depends_on = [random_string.deploy_id]
}
# Lambda base URL here
output "api_url" {
    description = "The base URL of the Lambda function"
    value = module.service.api_endpoint
}
output "rds_password" {
    description = "The password for the RDS instance"
    value = var.rds_password
    sensitive = true
}