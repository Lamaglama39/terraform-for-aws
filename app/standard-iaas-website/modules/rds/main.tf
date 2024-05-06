module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.app_name}-rds"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az          = var.multi_az

  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password
  password                    = var.password
  port                        = var.port

  vpc_security_group_ids = var.vpc_security_group_ids

  # Database Deletion Protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = true

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids

  # DB parameter group
  family = var.pg_family

  # DB option group
  major_engine_version = var.og_major_engine_version

  parameters = var.parameters
  options    = var.options
}
