/* ECR Repository */
resource "aws_ecr_repository" "ecr" {
  name                 = join("-", [var.app.name, "ecr"])
  image_tag_mutability = "MUTABLE"

  tags = {
    project = var.app.name
    latest  = var.app.version
    Name    = join("-", [var.app.name, "ecr"])
  }
}

resource "null_resource" "ecr" {
  triggers = {
    app_version = var.app.version
  }

  depends_on = [aws_ecr_repository.ecr]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook \
        -e aws_region=${var.aws_region} \
        -e aws_account_id=${data.aws_caller_identity.current.account_id} \
        -e docker_dir=../docker \
        -e project_name=${var.app.name} \
        -e app_version=${var.app.version} \
        ../ansible/image-build.yml \
    EOT
  }
}