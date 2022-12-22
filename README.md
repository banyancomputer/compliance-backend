# compliance-backend

What is it?

Django app with surround AWS hosted infrastructure managed by terraform

What does the django app do?
1. Allow unauthenticated users to read data through Lambda endpoints
2. Allow authenticated users to read/write data through Lambda endpoints

Repository Structure

- `app` - Django app

- `tf` - Terraform IaC
  - `build` - Build app as a docker image and deploy assets to ECR + S3
    - Uses a test image, not complete
    - Outputs repository url. Up to you to import that into terraform code along with valid version number
  - `deploy` - Deploy app to ECS wit necessary infrastructure
    -  `dev` - Deploys app in dev environment 
  - `modules` - Terraform modules for infrastructure
    - `build` - Build app and deploy assets to ECR + S3
    - `service` - Deploy app as a cloud service:
      - API Gateway
      - Django Lambda
      - S3 Cert Bucket
      - RDS Database