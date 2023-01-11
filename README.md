# compliance-backend

Django app with surround AWS hosted infrastructure managed by terraform

# What does the django app do?
1. Allow unauthenticated users to read data from a database
2. Allow authenticated users to write metadata to a database
2. Allow authenticated users to write data to an S3 bucket

# Respository structure:

## 'build/': Implements ECR with versioned Django docker images

### How to build and push a new version of the docker image:


## `dev/`: Implements a cloud deployment for development

### What does the surrounding infrastructure look like?
![Compliance Demo Architecture](.github/Compliance-Demo-Arch.jpg)

### What is the development comprised of?
1. Django app is hosted in an EC2 instance
2. An RDS instance is used to store metadata
3. An S3 bucket is used to store miner audit reports
4. An S3 bucket is used to store static files for the django app
5. An ALB for serving the django app
6. A VPC for hosting private resources

Repository Structure
- `build` - Build app as a docker image and deploy assets to ECR + S3
  - Uses a test image, not complete
  - Outputs repository url. Up to you to import that into terraform code along with valid version number
  - `deploy` - Deploy app to ECS wit necessary infrastructure
    -  `dev` - Deploys app in dev environment 
  - `modules` - Terraform modules for infrastructure
    - `service` - Deploy app as a cloud service:
      - API Gateway
      - Django Lambda
      - S3 Cert Bucket
      - RDS Database