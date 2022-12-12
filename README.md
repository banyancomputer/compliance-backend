# compliance-backend

What is it?

Django app with surround AWS hosted infrastructure managed by terraform

What infrastructure does it create?
1. Lambdas for running django app
2. API Gateway for routing requests to lambdas
3. S3 bucket for storing static files 
4. S3 bucket for storing Lambdas (maybe just ecr with django docker images?)
5. RDS database for storing data
6. Cloudfront for serving static files
7. VPC for endpoints
8. Security Groups for resource access
9. IAM roles for resource access
10. Cloudwatch for logging
11. Route53 for DNS

What does the django app do?
1. Allow unauthenticated users to read data through Lambda endpoints
2. Allow authenticated users to read/write data through Lambda endpoints