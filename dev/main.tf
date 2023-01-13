/* main.tf: Deploys our service with the desired configuration */

# Terraform Config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~> 1.3.0"

  # Our Remote State for Terraform on AWS
  # This bucket already exists in our AWS account
  backend "s3" {
      bucket = "banyan-tf-remote-state"
      key    = "compliance/dev/terraform.tfstate"
      region = "us-east-2"
  }
}

# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Random Strings for passwords and such

# Create a random string to keep track of deployments
resource "random_string" "deploy_id" {
  length  = 8
  special = false
  upper = false
}

# Create a random string for our RDS password
resource "random_string" "rds_password" {
  length  = 16
  special = false
}

# Create a random string for our Django secret key
resource "random_string" "django_secret_key" {
  length = 16
  special = false
}

# Create a random string for our Django superuser password
resource "random_string" "django_superuser_password" {
  length = 16
  special = false
}

/* Deploy the infrastructure for our service */
module "service" {
  source = "../modules/service"

  # AWS configuration
  aws_region = var.aws_region
  # Service configuration
  name = var.service_name
  stage  = var.service_stage
  deploy_id = random_string.deploy_id.result
  domain_name = var.service_domain_name

  # Default VPC config is fine for `dev`
  # Default RDS config is fine for `dev`
  # Default Ec2 Config is fine for `dev`

  # Set password for RDS instance
  rds_username = "rds_admin_user"
  rds_password = random_string.rds_password.result
}

/* Configure and provision our service */

# Provision the EC2 instance:
# - Populate a bash script with desired configuration
# - Copy the script to local machine
# - Run the script to provision the EC2 instance
# You can re-run this script to re-provision the EC2 instance
resource "null_resource" "ec2_provision" {
  triggers = {
    app_version = var.app_version
    provisioner = "${var.service_name}-ec2-provision.sh"

  }

  depends_on = [
    module.service.ec2_endpoint,
    module.service.rds_endpoint
  ]

  # Write our script to a file and execute it
  # You can now use the script to apply changes to the EC2 instance, even if terraform state is unaffected
  provisioner "local-exec" {
    command = <<-EOT
      echo ' \
        export ANSIBLE_HOST_KEY_CHECKING=False
        ansible-playbook \
          -i ${module.service.ec2_endpoint}, \
          -u ec2-user \
          --private-key ${module.service.ec2_priv_key_path} \
          --extra-vars "aws_region"="${var.aws_region}" \
          --extra-vars "ecr_url=${var.ecr_url}" \
          --extra-vars "app_version=${var.app_version}" \
          --extra-vars "django_debug=${var.django_debug}" \
          --extra-vars "django_secret_key=${random_string.django_secret_key.result}" \
          --extra-vars "django_allowed_hosts=${var.django_allowed_hosts}" \
          --extra-vars "django_sql_engine=${var.django_sql_engine}" \
          --extra-vars "django_superuser_username=${var.django_superuser_username}" \
          --extra-vars "django_superuser_password=${random_string.django_superuser_password.result}" \
          --extra-vars "django_superuser_email=${var.django_superuser_email}" \
          --extra-vars "django_use_s3=${var.django_use_s3}" \
          --extra-vars "django_aws_cert_bucket_name=${module.service.cert_bucket_name}" \
          --extra-vars "django_aws_cert_bucket_region=${var.aws_region}" \
          --extra-vars "django_sql_database=${module.service.rds_engine}" \
          --extra-vars "django_sql_user=rds_admin_user" \
          --extra-vars "django_sql_password=${random_string.rds_password.result}" \
          --extra-vars "django_sql_host=${split(":", module.service.rds_endpoint)[0]}" \
          --extra-vars "django_sql_port=${split(":", module.service.rds_endpoint)[1]}" \
          ./ansible/ec2-setup.yml \
      ' > ${self.triggers.provisioner}
      chmod +x ${self.triggers.provisioner}
      ./${self.triggers.provisioner}
    EOT
  }

  # Delete the script on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "rm ${self.triggers.provisioner}"
  }
}