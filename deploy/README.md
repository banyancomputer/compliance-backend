# Compliance Attestor Backend
## AWS Lambda (with gateway) + RDS + S3 + Cloudfront + Route53

## Progress

# Written up:

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

# Tested:

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

This Directory describes a development environment for the Compliance Attestor Backend. The backend is a Django app with surrounding AWS hosted infrastructure managed by terraform.

## Contents

`secret.tfvars.example` is a template for the variables that need to be set in order to deploy Estuary.  Copy this file to `secret.tfvars` and fill in the values.

`vars.tf` contains our default configuration for the components described in `main.tf`.

`main.tf` contains the Terraform configuration for deploying:

- ECR Repository
    - This is where the Django Docker image will be stored for loading onto a Lambda
- VPC
    - This is the Virtual Private Cloud that the Compliance backend will be deployed in.
- Internet Gateway
    - This is the gateway that allows the Compliance backend to communicate with the internet.
- Subnets
    - Public Subnet(s)
        - Lambda Gateway Subnet (Do we need )
            - See `vars.tf` for its Default CIDR Block.
            - It deployed accross one Availability Zone.
    - Private Subnet(s)
        - RDS Subnet Group
            - RDS requires at least 2 subnets in different availability zones.
            - See `vars.tf` for their Default CIDR Blocks.
            - They are deployed accross two Availability Zones.
            - The RDS Subnet Group is used to deploy the RDS instance.
- Routing Table
    - This routing table has a route to the internet gateway.
    - Associated w/ Public Subnet(s):
    - Associated w/ Private Subnet(s):
- Security Groups
    - Lambda Security Group
        - Associated w/ VPC
        - Ingress:
            - HTTP/S
        - Egress:
            - The Internet
    - RDS
        - Associated w/ VPC
        - Ingress:
            - RDS (Postgres) from EC2 Security Group
        - Egress:
            - The Internet
- Lamnbda + API Gateway

[//]: # (  - This Describes the Environment for the Compliance backend.)

[//]: # (  - Implements TLS Private Key: RSA / 4096 | Public Key pair)

[//]: # (    - TODO: Integrate with AWS KMS)

[//]: # (    - Outputs the private key to terraform.tfstate as an unencrypted output)

[//]: # (  - Implements a Role for Reading from the ECR Repository)

[//]: # (  - Configures an AMI)

[//]: # (    - This AMI is based on the latest Amazon Linux 2 AMI.)

[//]: # (  - Declares an Ec2 instance)

[//]: # (    - From AMI)

[//]: # (    - Associated w/ Ec2 Security Group)

[//]: # (    - Associated w/ TLS KEY)

[//]: # (    - Associated w/ ECR Role)

[//]: # (    - Associated w/ Public Subnet)

[//]: # (    - Installs Docker)

[//]: # (  - Elastic IP)

[//]: # (    - This is the Elastic IP that the Compliance backend will be deployed in.)

[//]: # (    - Associated w/ EC2 Instance)
- RDS Instance
    - Postgres
    - See `vars.tf` for its Default Configuration.
    - Associated w/ RDS Subnet Group

`outputs.tf` describes the outputs of the Terraform configuration.
It returns:
- The Elastic IP of the Compliance backend.
- The RDS Endpoint.

## Deployment
1. Deploy our infrastructure with Terraform:
```bash
$ terraform init
$ terraform plan -var-file=secret.tfvars
$ terraform apply -var-file=secret.tfvars
```
2. Push our Docker image to ECR:
```bash
$ aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCT_NUMBER>.dkr.ecr.<AWS_REGION>.amazonaws.com
$ docker build -t <PROJECT-NAME>-ecr .
$ docker tag <PROJECT-NAME>-ecr:latest <AWS_ACCT_NUMBER>.dkr.ecr.<AWS_REGION>.amazonaws.com/<PROJECT-NAME>-ecr:latest
$ docker push <AWS_ACCT_NUMBER>.dkr.ecr.<AWS_REGION>.amazonaws.com/<PROJECT-NAME>-ecr:latest
```

### Prerequisites

