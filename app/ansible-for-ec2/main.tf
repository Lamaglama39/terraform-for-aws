module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.app_name}-vpc"
  cidr = local.vpc_cidr_block

  azs             = local.subnet_azs
  private_subnets = local.private_subnet_cidr_block
  public_subnets  = local.public_subnet_cidr_block

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
  role_name         = "${local.app_name}-ec2-role"

  create_instance_profile = true
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
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

  tags = {
    app = local.app_name
  }
}

module "ec2_client" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = local.client_instances_map

  name          = "${local.app_name}-${each.value.name}-ec2"
  instance_type = each.value.instance_type

  iam_instance_profile   = module.iam_assumable_role.iam_instance_profile_name
  key_name               = module.key_pair.key_pair_name
  vpc_security_group_ids = [module.vote_service_sg["private"].security_group_id]
  subnet_id              = module.vpc.public_subnets[tonumber(each.key)]

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  user_data                   = each.value.user_data

  tags = {
    app = local.app_name
  }
}

resource "null_resource" "copy_file_to_ec2" {
  for_each = module.ec2_server

  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} -o StrictHostKeyChecking=no ${local.private_key_file} ec2-user@${each.value.public_ip}:/home/ec2-user/.ssh"
  }
  provisioner "local-exec" {
    command = "scp -r -i ${local.private_key_file} -o StrictHostKeyChecking=no ${path.module}/conf/.ssh ec2-user@${each.value.public_ip}:/home/ec2-user/"
  }
  provisioner "local-exec" {
    command = "scp -r -i ${local.private_key_file} -o StrictHostKeyChecking=no ${path.module}/conf/ansible ec2-user@${each.value.public_ip}:/home/ec2-user/"
  }

  depends_on = [module.ec2_server]
}
