/* ecr.tf:
 * Provisions an ECR repository for the given service.
 * Pushes Semantically versioned Docker images to the repository.
 */

# Who's deploying this image?
data "aws_caller_identity" "current" {}

/* ECR Repository */
resource "aws_ecr_repository" "ecr" {
  name                 = join("-", [var.app_name, "ecr"])
  # Tags can't be modified after creation.
  image_tag_mutability = "IMMUTABLE"
  # Set force destroy to true to delete the repository and all images. Be careful!
  force_delete        = true

  tags = {
    Name = join("-", [var.app_name, "ecr"])
  }
}

/* ECR Image Build-Push resource. Gets run when app_version is changed */
resource "null_resource" "ecr" {
  # Only run when app_version changes.
  triggers = {
    app_version = var.app_version
  }

  # Depends on the ECR repository being created.
  depends_on = [aws_ecr_repository.ecr]

  # Build and push the image using our Dockerfile and Ansible playbook.
  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook \
        -e aws_region=${var.aws_region} \
        -e aws_account_id=${data.aws_caller_identity.current.account_id} \
        -e app_name=${var.app_name} \
        -e app_version=${var.app_version} \
        ./ansible/image-build-push.yml \
    EOT
  }
}