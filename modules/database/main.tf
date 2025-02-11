# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}db-subnet"
  subnet_ids = var.private_subnets

  tags = merge(local.tags, {
    Name = "${local.name_prefix}db-subnet-group"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${local.name_prefix}db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_type

  # Storage
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.database_sg_id]

  # Credentials from SSM
  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value

  # Backup and maintenance
  backup_retention_period = 7
  skip_final_snapshot     = true
  multi_az                = false

  tags = merge(local.tags, {
    Name = "${local.name_prefix}mysql"
  })
}
