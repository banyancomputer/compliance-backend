output "deploy_id" {
    description = "The ID of the deployment"
    value = random_string.deploy_id.result
    depends_on = [random_string.deploy_id]
}
# Lambda base URL here
output "lambda_base_url" {
    description = "The base URL of the Lambda function"
    value = module.service.api_endpoint
}

# Cloudfront base URL here

# RDS Endpoint
#output "rds_endpoint" {
#    description = "The RDS endpoint"
#    value = aws_db_instance.rds.endpoint
#    depends_on = [aws_db_instance.rds]
#}
## RDS Port
#output "rds_port" {
#    description = "The RDS port"
#    value = aws_db_instance.rds.port
#    depends_on = [aws_db_instance.rds]
#}
