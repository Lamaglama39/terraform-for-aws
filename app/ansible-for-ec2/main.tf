module "main" {
  source = "../../module/ansible-for-ec2"

  default_tag = local.default_tag
  region      = local.region
  app_name    = local.app_name

  vpc_cidr_block            = local.vpc_cidr_block
  public_subnet_cidr_block  = local.public_subnet_cidr_block
  private_subnet_cidr_block = local.private_subnet_cidr_block
  public_subnet_az          = local.public_subnet_az
  private_subnet_az         = local.private_subnet_az

  instance_type    = local.instance_type
  server_instances = local.server_instances
  client_instances = local.client_instances
}
