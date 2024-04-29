module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.app_name}-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.subnet_azs
  public_subnets  = var.public_subnet_cidr_block
}
