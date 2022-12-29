data "aws_caller_identity" "current" {}

/* ECR Repository */
resource "aws_ecr_repository" "ecr" {
  name                 = join("-", [var.app_name, "ecr"])
  # Let us update the image tag manually
  image_tag_mutability = "MUTABLE"
  # Force destroy the repository on `terraform destroy`. Be CAREFUL!
  force_delete        = true

  tags = {
    Name    = join("-", [var.app_name, "ecr"])
  }
}

/* ECR Population hook */
resource "null_resource" "ecr" {
  triggers = {
    app_version = var.app_version
  }

  depends_on = [aws_ecr_repository.ecr]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook \
        -e aws_region=${var.aws_region} \
        -e aws_account_id=${data.aws_caller_identity.current.account_id} \
        -e app_name=${var.app_name} \
        -e app_version=${var.app_version} \
        ./ansible/image-build.yml \
    EOT
  }
}