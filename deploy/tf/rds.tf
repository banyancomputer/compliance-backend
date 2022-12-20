## RDS Deployment
#
#/* Declare a Subnet group for our RDS instance */
#resource "aws_db_subnet_group" "rds" {
#  name        = join("-", [var.app.name, "rds-subnet-group", random_string.deploy_id.result])
#  description = "Subnet group for our RDS instance"
#  subnet_ids  = aws_subnet.private[*].id # Neato!
#  tags        = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "rds-subnet-group"])
#  }
#}
#
#/* RDS Instance */
#resource "aws_db_instance" "rds" {
#  identifier             = join("-", [var.app.name, "rds", random_string.deploy_id.result])
#  allocated_storage      = tonumber(var.settings.rds.allocated_storage)
#  engine                 = var.settings.rds.engine
#  engine_version         = var.settings.rds.engine_version
#  instance_class         = var.settings.rds.instance_class
#  db_name                = var.settings.rds.db_name
#  username               = var.rds_username
#  password               = var.rds_password
#  db_subnet_group_name   = aws_db_subnet_group.rds.id
#  vpc_security_group_ids = [
#    aws_security_group.rds.id
#  ]
#  skip_final_snapshot = tobool(var.settings.rds.skip_final_snapshot)
#  tags                = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "rds"])
#  }
#}