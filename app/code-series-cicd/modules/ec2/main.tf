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
