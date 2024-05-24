resource "aws_s3_bucket" "main" {
  bucket_prefix = "${var.app_name}-"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket   = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket   = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket   = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_type
      kms_master_key_id = var.encryption_type == "aws:kms" || var.encryption_type == "aws:kms:dsse" ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.encryption_type == "aws:kms" ? true : null
  }
}
