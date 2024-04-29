module "ec2" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = var.server_instances_map

  name          = "${var.app_name}-ec2"
  instance_type = each.value.instance_type

  iam_instance_profile   = module.iam_assumable_role.iam_instance_profile_name
  vpc_security_group_ids = [module.vote_service_sg["public"].security_group_id]
  subnet_id              = module.vpc.public_subnets[tonumber(each.key)]

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  user_data                   = each.value.user_data
}

module "vote_service_sg" {
  source   = "terraform-aws-modules/security-group/aws"
  for_each = var.security_groups

  name        = "${var.app_name}-${each.value.name}-sg"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = each.value.ingress_cidr_blocks
  ingress_with_cidr_blocks = [
    {
      from_port   = each.value.ingress_with_cidr_blocks.from_port
      to_port     = each.value.ingress_with_cidr_blocks.to_port
      protocol    = each.value.ingress_with_cidr_blocks.protocol
      description = each.value.ingress_with_cidr_blocks.description
    }
  ]
  egress_cidr_blocks = each.value.egress_cidr_blocks
  egress_with_cidr_blocks = [
    {
      from_port   = each.value.egress_with_cidr_blocks.from_port
      to_port     = each.value.egress_with_cidr_blocks.to_port
      protocol    = each.value.egress_with_cidr_blocks.protocol
      description = each.value.egress_with_cidr_blocks.description
    }
  ]
}

module "iam_assumable_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  role_requires_mfa = false
  create_role       = true
  role_name         = "${var.app_name}-ec2-role"

  create_instance_profile = true
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
}
