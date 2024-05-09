data "aws_caller_identity" "self" { }

module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "${var.app_name}-${var.primary_region}-efs"
  encrypted      = var.encrypted
  kms_key_arn    = var.kms_key_arn
  lifecycle_policy = var.lifecycle_policy

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = false

  # Mount targets / security group
  mount_targets = var.mount_targets
  security_group_vpc_id      = var.security_group_vpc_id
  # security_group_description = "Example EFS security group"
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = var.sg_cidr_blocks
    }
  }

  # Backup policy
  enable_backup_policy = true

  # Replication configuration
  create_replication_configuration = true
  replication_configuration_destination = {
    region = var.secondary_region
  }
}
