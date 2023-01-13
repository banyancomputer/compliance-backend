/* rds.tf: deploy an RDS instance withing a VPC */

# Subnet group for the RDS instance
resource "aws_db_subnet_group" "rds" {
  name        = join("-", [var.name, "rds-subnet-group", var.stage, var.deploy_id])
  description = "Subnet group for our RDS instance"
  subnet_ids  = aws_subnet.private[*].id
  tags        = {
    deploy_id    = var.deploy_id
    stage        = var.stage
    service_name = var.name
    name         = join("-", [var.name, "rds-subnet-group"])
  }
}
# RDS instance security group
resource "aws_security_group" "rds" {
  name        = join("-", [var.name, "rds-sg", var.stage, var.deploy_id])
  description = "Security Group for our RDS instance"
  vpc_id      = aws_vpc.vpc.id

  # Allow inbound traffic from the VPC to PostgreSQL port
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL"
    cidr_blocks = [
      aws_vpc.vpc.cidr_block
    ]
  }

  # Allow egress to PostgreSQL port inside the VPC
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL"
    cidr_blocks = [
      aws_vpc.vpc.cidr_block
    ]
  }

  tags = {
    deploy_id    = var.deploy_id
    stage        = var.stage
    service_name = var.name
    name         = join("-", [var.name, "rds-sg"])
  }
}
# RDS instance
resource "aws_db_instance" "rds" {
  # The name of our RDS instance
  identifier             = join("-", [var.name, "rds", var.stage, var.deploy_id])
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  # Instance class and configuration
  allocated_storage   = tonumber(var.rds_config.allocated_storage)
  engine              = var.rds_config.engine
  engine_version      = tostring(var.rds_config.engine_version)
  instance_class      = var.rds_config.instance_class
  skip_final_snapshot = tobool(var.rds_config.skip_final_snapshot)

  # DB connection configuration
  db_name  = var.rds_config.db_name
  username = var.rds_username
  password = var.rds_password

  tags = {
    deploy_id    = var.deploy_id
    stage        = var.stage
    service_name = var.name
    name         = join("-", [var.name, "rds"])
  }
}