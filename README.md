# compliance-backend

Note: the documentation here isn't extensive. If you need more information, please contact alex@banyan.computer.

Deploys a django app with surround AWS hosted infrastructure managed by terraform
Django app is implemented in `compliance-django-app` repository

To use this repository, you must have the following installed:
- terraform
- aws cli (configured with your credentials)
- ansible

# Repository structure:

## 'build/': Implements ECR with versioned Django docker images

This terraform module provisions a private Elastic Container Repository (ECR).
The ECR is meant to be filled with images tagged with semantic versioning.
Images are built using the dockerfile at `/build/docker/Dockerfile` 
Images are based on code pulled from the "main" branch of the `compliance-django-app` repository.
See that repository for more information on the django service and how it should be configured.

### How to build and push a new version of the docker image:

Run
```
$ cd build
$ terraform init
$ terraform apply
```
You should be prompted for the version of the image you want to build and push.
This will build and push the image to ECR.
Run:
```
$ terraform output
```
to see where the ECR repository is located.
Use this URL and the version you specified to deploy the service to AWS. See below for more information.

### Teardown
Run
```
$ terraform destroy
```
In order to remove the ECR repository and all of its images.

## `dev/`: Implements a cloud deployment for development

### Pre-requisites
If you want to use this out of the box, you will need to have an S3 bucket created to store your terraform state.
If you are a Banyan employee, you can use the `banyan-tf-remote-state` bucket at `us-east-2`.
See the `dev/main.tf` for more info on configuring this backend, or to do away with it.

### Deployed infrastructure

See `modules/service/` for a description of the infrastructure deployed by this module.
The result is a single Ec2 instance accessible at a custom domain name over HTTPS.

### How is the Django app deployed in the instance?
![Compliance Demo Deployment](.github/ec2-dev.png)

The Django handler is served by a Gunicorn server.
The Gunicorn server is run in a Docker container.
The Docker container is proxied by an Nginx server.
The Nginx server is accessed through the ELB.

### How to deploy the service to AWS

#### Configure the service

Go to `dev/vars.tf` and change any variables you want to change. Everything is fine as is except for:
- 'app_version': This should be the version of the docker image you want to deploy. See the `build/` directory for more information on how to build and push a new version of the docker image.

#### Deploy the service

Run
```
$ cd dev
$ terraform init
$ terraform apply
```
This will deploy the service to AWS. This will configure the Ec2 to run the docker image you specified in `app_version`.
Run:
```
$ terraform output
```
For information on how to access the service. Important outputs are:
- ec2_endpoint: The public DNS name of the Ec2 instance
- ec2_priv_key_path: The path to the private key used to access the Ec2 instance. Use this to ssh into the instance for debugging.
- elb_dns_name: The public DNS name of the ELB. You can use this to access the service over HTTP.
- elb_endpoint: The custom DNS name of the ELB. You can use this to access the service over HTTPS.
- django_superuser_password: The password for the django superuser. Use this to log into the django admin interface. This is a sensitive value so you will have to call `terraform output django_superuser_password` to see it.
 to inspect this value.
- rds_password: The password for the RDS database. This is a sensitive value so you will have to call `terraform output rds_password` to see it.

The service should be available at the `elb_endpoint` URL in a few minutes. 

If you need to reprovision the Ec2 instance, you can run:
```
$ ./compliance-ec2-provision.sh
```
 in the `dev/` directory. This will run the ansible playbook that provisions the Ec2 instance.

#### Teardown
Run
```
$ terraform destroy
```

This deletes any files, keys, and resources created by this module.

## `modules/service`: Reusable terraform module for the infrastructure for our django service.

### What does the surrounding infrastructure look like?
![Compliance Demo Architecture](.github/Compliance-Demo-Arch.png)

### What is the development env comprised of?
1. Django app is hosted in an EC2 instance
2. An RDS instance is used to store metadata
3. A public S3 bucket is used to store miner audit reports
5. An ELB for serving the django app
6. A VPC for hosting private resources
7. A Route53 zone for providing a custom domain name for serving the django app through HTTPS through the ELB
8. Security groups for the ELB, EC2 instance and RDS instance that protect resources from unauthorized access
9. Subnets for hosting the EC2 instance and RDS instance

See `modules/service/` for more information on the infrastructure deployed by this module.
See `modules/service/var.tf` for more information on the variables that can be configured for this module.