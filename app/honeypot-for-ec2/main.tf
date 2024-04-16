module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.app_name}-vpc"
  cidr = local.vpc_cidr_block

  azs            = local.subnet_azs
  public_subnets = local.public_subnet_cidr_block

  tags = {
    app = local.app_name
  }
}

resource "tls_private_key" "this" {
  algorithm = local.key_algorithm
}

resource "local_file" "private_key_pem" {
  filename        = local.private_key_file
  content         = tls_private_key.this.private_key_openssh
  file_permission = "0600"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name              = "${local.app_name}-key"
  public_key            = tls_private_key.this.public_key_openssh
  private_key_algorithm = local.key_algorithm
}

module "vote_service_sg" {
  source   = "terraform-aws-modules/security-group/aws"
  for_each = local.security_groups

  name        = "${local.app_name}-${each.value.name}-sg"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks       = each.value.ingress_cidr_blocks
  ingress_with_cidr_blocks  = each.value.ingress_with_cidr_blocks
  egress_cidr_blocks        = each.value.egress_cidr_blocks
  egress_with_cidr_blocks   = each.value.egress_with_cidr_blocks
}

module "iam_assumable_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  role_requires_mfa = false
  create_role       = true
  role_name         = "${local.app_name}-ec2-role"

  create_instance_profile = true
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

module "ec2_server" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = local.server_instances_map

  name          = "${local.app_name}-${each.value.name}-ec2"
  instance_type = each.value.instance_type

  iam_instance_profile   = module.iam_assumable_role.iam_instance_profile_name
  key_name               = module.key_pair.key_pair_name
  vpc_security_group_ids = [module.vote_service_sg["public"].security_group_id]
  subnet_id              = module.vpc.public_subnets[tonumber(each.key)]

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  user_data                   = each.value.user_data

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      iops = 3000
      throughput  = 125
      volume_size = 150
    }
  ]

  tags = {
    app = local.app_name
  }
}
