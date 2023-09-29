locals {
  name = "postgres"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "task-management"

  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = "db.t4g.small"

  allocated_storage = 20

  db_name  = "tasks"
  username = local.db_creds.username
  password = local.db_creds.password
  port     = 5432
  manage_master_user_password = false

  multi_az     = false
  storage_type = "gp3"

  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [module.security_group.security_group_id]


}



module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-sg"
  description = "Allow access from within VPC"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "${local.name}-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "database_secret" {
  name = "postgres-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_secret.id
  secret_string = <<EOF
  {
    "username": "postgres",
    "password": "${random_password.db_password.result}"
  }
  EOF
}

data "aws_secretsmanager_secret" "database_secret" {
  arn = aws_secretsmanager_secret.database_secret.arn
}

data "aws_secretsmanager_secret_version" "database_secret_version" {
  secret_id = aws_secretsmanager_secret.database_secret.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.database_secret_version.secret_string)
}