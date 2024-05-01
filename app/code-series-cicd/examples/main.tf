module "code-series" {
  source = "../modules/code-series"

  app_name        = local.app_name
  build_bucket    = local.build_bucket
  pipeline_bucket = local.pipeline_bucket
  default_branch  = local.default_branch
  ec2_tag_filter  = local.ec2_tag_filter
}

module "s3_build_bucket" {
  source = "../modules/s3"

  bucket_name = local.build_bucket
}

module "s3_pipeline_bucket" {
  source = "../modules/s3"

  bucket_name = local.pipeline_bucket
}

module "vpc" {
  source = "../modules/network"

  app_name                 = local.app_name
  public_subnet_cidr_block = local.public_subnet_cidr_block
  vpc_cidr_block           = local.vpc_cidr_block
  subnet_azs               = local.subnet_azs
}

module "ec2" {
  source = "../modules/ec2"

  for_each =  toset(module.vpc.vpc.public_subnets)
  app_name  = local.app_name
  vpc_id    = module.vpc.vpc.vpc_id
  subnet_id = each.value

  server_instances_map = local.server_instances_map
  security_groups      = local.security_groups_map
}
