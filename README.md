# compliance-backend

What is it?

Django app with surround AWS hosted infrastructure managed by terraform

What infrastructure does it create? 
- [ ] Lambdas for running django app
- [ ] API Gateway for routing requests to lambdas 
- [ ] S3 bucket for storing static files
- [ ] ECR for storing Lambdas
- [ ] RDS database for storing data
- [ ] Cloudfront for serving static files
- [ ] VPC for endpoints
- [ ] Security Groups for resource access
- [ ] IAM roles for resource access
- [ ] Cloudwatch for logging
- [ ] Route53 for DNS

What does the django app do?
1. Allow unauthenticated users to read data through Lambda endpoints
2. Allow authenticated users to read/write data through Lambda endpoints