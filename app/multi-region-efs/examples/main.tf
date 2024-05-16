module "vpc" {
  source = "../modules/network"

  app_name                  = "${local.app_name}-${local.vpc_region1.region}"
  vpc_cidr_block            = local.vpc_region1.vpc_cidr_block
  subnet_azs                = local.vpc_region1.subnet_azs
  public_subnet_cidr_block  = local.vpc_region1.public_subnet_cidr_block
  private_subnet_cidr_block = local.vpc_region1.private_subnet_cidr_block
}

module "vpc_replica" {
  source = "../modules/network"

  providers                 = { aws = aws.replica }
  app_name                  = "${local.app_name}-${local.vpc_region2.region}"
  vpc_cidr_block            = local.vpc_region2.vpc_cidr_block
  subnet_azs                = local.vpc_region2.subnet_azs
  public_subnet_cidr_block  = local.vpc_region2.public_subnet_cidr_block
  private_subnet_cidr_block = local.vpc_region2.private_subnet_cidr_block
}

module "sg" {
  source = "../modules/sg/group"

  for_each        = local.security_groups
  app_name        = local.app_name
  vpc_id          = module.vpc.vpc.vpc_id
  security_groups = each.value
}

module "sg_replica" {
  source = "../modules/sg/group"

  providers       = { aws = aws.replica }
  for_each        = local.security_groups
  app_name        = local.app_name
  vpc_id          = module.vpc_replica.vpc.vpc_id
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

module "sg_rule_replica" {
  source = "../modules/sg/rule"

  providers  = { aws = aws.replica }
  for_each   = local.sg_rules_replica
  app_name   = local.app_name
  vpc_id     = module.vpc_replica.vpc.vpc_id
  sg_rules   = each.value
  depends_on = [module.sg_replica]
}

module "iam_role" {
  source = "../modules/iam"

  app_name                 = local.app_name
  trusted_role_services    = local.trusted_role_services
  instance_iam_policy_arns = local.instance_iam_policy_arns
}

module "key_pair" {
  source = "../modules/key_pair"

  app_name         = local.app_name
  key_algorithm    = local.key_algorithm
  private_key_file = local.private_key_file
}

module "key_pair_replica" {
  source = "../modules/key_pair"

  providers        = { aws = aws.replica }
  app_name         = local.app_name
  key_algorithm    = local.key_algorithm
  private_key_file = local.private_key_file_replica
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
  depends_on           = [module.efs]
}

module "ec2_replica" {
  source = "../modules/ec2"

  providers              = { aws = aws.replica }
  for_each               = toset(module.vpc_replica.vpc.public_subnets)
  app_name               = local.app_name
  vpc_id                 = module.vpc_replica.vpc.vpc_id
  subnet_id              = each.value
  vpc_security_group_ids = [module.sg_replica.ec2.sg.id]
  iam_role               = module.iam_role.iam_role.iam_instance_profile_name
  key_name               = module.key_pair_replica.key_pair.key_pair_name

  server_instances_map = local.server_instances_replica
  depends_on           = [module.efs_secondary]
}

module "efs" {
  source = "../modules/efs"

  app_name        = local.app_name
  region          = local.primary_region
  subnet_id       = module.vpc.vpc.private_subnets[0]
  security_groups = [module.sg.efs.sg.id]
}

module "efs_secondary" {
  source = "../modules/efs"

  providers       = { aws = aws.replica }
  app_name        = local.app_name
  region          = local.secondary_region
  subnet_id       = module.vpc_replica.vpc.private_subnets[0]
  security_groups = [module.sg_replica.efs.sg.id]
}

module "efs_replication" {
  source = "../modules/efs_replication"

  source_file_system_id = module.efs.efs.id
  replication_file_system_id = module.efs_secondary.efs.id
  replication_region = local.secondary_region
}

# module "efs_replication_secondary" {
#   source = "../modules/efs_replication"

#   providers       = { aws = aws.replica }
#   source_file_system_id = module.efs_secondary.efs.id
#   replication_file_system_id = module.efs.efs.id
#   replication_region = local.primary_region
# }
