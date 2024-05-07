module "vpc" {
  source = "../modules/network"

  app_name                  = local.app_name
  vpc_cidr_block            = local.vpc_cidr_block
  subnet_azs                = local.subnet_azs
  public_subnet_cidr_block  = local.public_subnet_cidr_block
  private_subnet_cidr_block = local.private_subnet_cidr_block
}

module "iam_role" {
  source = "../modules/iam"

  app_name                 = local.app_name
  trusted_role_services    = local.trusted_role_services
  instance_iam_policy_arns = local.instance_iam_policy_arns
}

module "sg" {
  source = "../modules/sg/group"

  for_each        = local.security_groups
  app_name        = local.app_name
  vpc_id          = module.vpc.vpc.vpc_id
  security_groups = each.value
}

module "sg_rule" {
  source = "../modules/sg/rule"

  for_each   = local.sg_rules
  app_name   = local.app_name
  vpc_id     = module.vpc.vpc.vpc_id
  sg_rules   = each.value
  depends_on = [module.sg]
}

module "elb" {
  source = "../modules/elb"

  app_name            = local.app_name
  vpc_id              = module.vpc.vpc.vpc_id
  nlb_subnet          = module.vpc.vpc.public_subnets
  nlb_security_groups = [module.sg.nlb.sg.id]

  alb_subnet          = module.vpc.vpc.public_subnets
  alb_security_groups = [module.sg.alb.sg.id]

  instance_id = flatten([
    for subnet_key in keys(module.ec2) : [
      for ec2_key in keys(module.ec2[subnet_key]["ec2"]) :
      module.ec2[subnet_key]["ec2"][ec2_key]["id"]
    ]
  ])
}

module "key_pair" {
  source = "../modules/key_pair"

  app_name         = local.app_name
  key_algorithm    = local.key_algorithm
  private_key_file = local.private_key_file
}

module "ec2" {
  source = "../modules/ec2"

  for_each               = toset(module.vpc.vpc.public_subnets)
  app_name               = local.app_name
  vpc_id                 = module.vpc.vpc.vpc_id
  subnet_id              = each.value
  vpc_security_group_ids = [module.sg.ec2.sg.id]
  iam_role               = module.iam_role.iam_role.iam_instance_profile_name
  key_name               = module.key_pair.key_pair.key_pair_name

  server_instances_map = local.server_instances
  depends_on           = [module.vpc]
}

module "rds" {
  source = "../modules/rds"

  app_name            = local.app_name
  engine              = local.engine
  engine_version      = local.engine_version
  instance_class      = local.instance_class
  allocated_storage   = local.allocated_storage
  multi_az            = local.multi_az
  deletion_protection = local.deletion_protection

  db_name                     = local.db_name
  username                    = local.username
  manage_master_user_password = false
  password                    = var.password
  port                        = local.port

  vpc_security_group_ids  = [module.sg.rds.sg.id]
  subnet_ids              = module.vpc.vpc.private_subnets
  pg_family               = local.pg_family
  og_major_engine_version = local.og_major_engine_version
  parameters              = local.parameters
  options                 = local.options
}
