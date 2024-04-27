module "code-series" {
  source = "../modules/code-series"

  app_name              = local.app_name
  build_artifact_bucket = local.build_artifact_bucket
  pipeline_bucket       = local.pipeline_bucket
  default_branch        = local.default_branch
  ec2_tag_filter        = local.ec2_tag_filter

  public_subnet_cidr_block = local.public_subnet_cidr_block
  vpc_cidr_block           = local.vpc_cidr_block
  subnet_azs               = local.subnet_azs
  server_instances_map     = local.server_instances_map
  security_groups          = local.security_groups_map
}
