#/* Security Groups */

#
## RDS Security Group
#resource "aws_security_group" "rds" {
#  name        = join("-", [var.app.name, "rds-sg", random_string.deploy_id.result])
#  description = "Security Group for our RDS instance"
#  vpc_id      = aws_vpc.vpc.id
#
#  # Allow inbound traffic from the EC2 instance
#  ingress {
#    from_port   = 5432
#    to_port     = 5432
#    protocol    = "tcp"
#    description = "PostgreSQL"
#    cidr_blocks = [
#      aws_vpc.vpc.cidr_block
#    ]
#  }
#
#  # Allow all outbound traffic.
#  egress {
#    from_port = 0
#    to_port   = 0
#    protocol  = "-1"
#  }
#
#  tags = {
#    deployment_id = random_string.deploy_id.result
#    project       = var.app.name
#    Name          = join("-", [var.app.name, "rds-sg"])
#  }
#}