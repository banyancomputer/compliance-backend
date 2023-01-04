# Deprecated until need for static assets is determined

#/* Create S3 bucket for Static Django Assets */
#resource "aws_s3_bucket" "s3" {
#  bucket = join("-", [var.app_name, "static-assets"])
#  # Set force destroy to true to delete the repository and all images. Be careful!
#  force_destroy        = true
#
#  tags   = {
#    Name = join("-", [var.app_name, "static-assets"])
#  }
#}
#
#/* Static Assets Bucket Push Resource. Gets run when the app version is updated */
#resource "null_resource" "s3" {
#  # Only run when app_version changes.
#  triggers = {
#    app_version = var.app_version
#  }
#
#  # Depends on the ECR repository being created.
#  depends_on = [aws_s3_bucket.s3]
#
#  # Build and push the image using our Dockerfile and Ansible playbook.
#  provisioner "local-exec" {
#    command = <<-EOT
#      ansible-playbook \
#        -e aws_region=${var.aws_region} \
#        -e aws_s3_bucket=${aws_s3_bucket.s3.id} \
#        -e app_version=${var.app_version} \
#        ./ansible/static-assets-push.yml
#    EOT
#  }
#}