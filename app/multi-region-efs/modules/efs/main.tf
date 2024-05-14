resource "aws_efs_file_system" "main" {
  creation_token = "${var.app_name}-${var.region}-efs"
  encrypted      = var.encrypted
  kms_key_id     = var.kms_key_arn

  protection {
    replication_overwrite = "DISABLED"
  }
  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = {
    Name = "${var.app_name}-${var.region}-efs"
  }
}

data "aws_caller_identity" "self" {}
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "ExampleStatement01"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.self.account_id
      }:root"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.main.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "main" {
  file_system_id = aws_efs_file_system.main.id
  policy         = data.aws_iam_policy_document.policy.json
}

resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_id
  security_groups = var.security_groups
}
