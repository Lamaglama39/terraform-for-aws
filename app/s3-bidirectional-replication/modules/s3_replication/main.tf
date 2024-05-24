# IAM
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetReplicationConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold",
    ]

    resources = [
      "arn:aws:s3:::${var.source_s3_bucket}",
      "arn:aws:s3:::${var.source_s3_bucket}/*",
      "arn:aws:s3:::${var.replication_s3_bucket}",
      "arn:aws:s3:::${var.replication_s3_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
    ]

    resources = [
      "arn:aws:s3:::${var.source_s3_bucket}/*",
      "arn:aws:s3:::${var.replication_s3_bucket}/*",
    ]
  }

  dynamic "statement" {
    for_each = var.source_kms_key_id != null ? [var.source_kms_key_id] : []
    content {
      effect = "Allow"

      actions = [
        "kms:Decrypt",
      ]

      resources = [
        "${statement.value}"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.replica_kms_key_id != null ? [var.replica_kms_key_id] : []
    content {
      effect = "Allow"

      actions = [
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ]

      resources = [
        "${statement.value}"
      ]
    }
  }
}

resource "aws_iam_policy" "main" {
  name   = "${var.app_name}-s3-replication-iam-policy"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role" "main" {
  name               = "${var.app_name}-s3-replication-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

# Replication Configuration
resource "aws_s3_bucket_replication_configuration" "main" {
  role   = aws_iam_role.main.arn
  bucket = var.source_s3_bucket

  rule {
    id = "replication"

    status = "Enabled"

    dynamic "source_selection_criteria" {
      for_each = var.replica_kms_key_id != null ? ["Enabled"] : []
      content {
        sse_kms_encrypted_objects {
          status = source_selection_criteria.value
        }
      }
    }

    destination {
      bucket        = "arn:aws:s3:::${var.replication_s3_bucket}"
      storage_class = "STANDARD"
      dynamic "encryption_configuration" {
        for_each = var.replica_kms_key_id != null ? [var.replica_kms_key_id] : []
        content {
          replica_kms_key_id = encryption_configuration.value
        }
      }
    }
  }
}
