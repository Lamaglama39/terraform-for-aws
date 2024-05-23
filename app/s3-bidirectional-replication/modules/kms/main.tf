data "aws_caller_identity" "current" {}

resource "aws_kms_key" "main" {
  description             = "S3 Server Side Encryption KMS"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.app_name}"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}
