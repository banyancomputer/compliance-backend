/* rds.tf: deploy an RDS instance withing a VPC */

# Subnet group for the RDS instance
resource "aws_db_subnet_group" "rds" {
  name        = join("-", [var.app.name, "rds-subnet-group", var.deploy_id])
  description = "Subnet group for our RDS instance"
  subnet_ids  = var.subnets_config.private_subnets[*] # Neato!
  tags        = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "rds-subnet-group"])
  }
}
# RDS instance security group
resource "aws_security_group" "rds" {
  name        = join("-", [var.app.name, "rds-sg", var.deploy_id])
  description = "Security Group for our RDS instance"
  vpc_id      = var.vpc_config.vpc_id
  # Allow inbound traffic from the RDS instance
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL"
    cidr_blocks = [
      var.vpc_config.cidr_block,
    ]
    self = true
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL"
    cidr_blocks = [
      var.vpc_config.cidr_block,
    ]
    self = true
  }

  tags = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "rds-sg"])
  }
}
# RDS instance
resource "aws_db_instance" "rds" {
  identifier             = join("-", [var.app.name, "rds", var.deploy_id])
  allocated_storage      = tonumber(var.rds_config.allocated_storage)
  engine                 = "postgres"
  engine_version         = 14
  instance_class         = var.rds_config.instance_class
  db_name                = var.rds_config.db_name
  # Django expects a database user named 'postgres'
  username               = "postgres"
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
  skip_final_snapshot = tobool(var.rds_config.skip_final_snapshot)
  tags                = {
    deployment_id = var.deploy_id
    project       = var.app.name
    Name          = join("-", [var.app.name, "rds"])
  }
}