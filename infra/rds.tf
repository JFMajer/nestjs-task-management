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

  db_name                     = "tasks"
  username                    = "postgres"
  password                    = var.db_password
  port                        = 5432
  manage_master_user_password = false

  multi_az            = false
  storage_type        = "gp3"
  apply_immediately   = true
  skip_final_snapshot = true

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
