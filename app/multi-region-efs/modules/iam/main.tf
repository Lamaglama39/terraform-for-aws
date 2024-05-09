module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = var.trusted_role_services

  role_requires_mfa = false
  create_role       = true
  role_name         = "${var.app_name}-ec2-role"

  create_instance_profile = true
  custom_role_policy_arns = var.instance_iam_policy_arns
}
