# SFTPアクセス先S3
resource "aws_s3_bucket" "bucket_1" {
  provider      = aws.account2
  bucket_prefix = "s3-${var.project}-${var.account1}-1"
  force_destroy = true
}

# bucket policy
resource "aws_s3_bucket_policy" "bucket_1" {
  provider = aws.account2
  bucket   = aws_s3_bucket.bucket_1.id
  policy   = data.aws_iam_policy_document.policy_document_1.json
}

data "aws_iam_policy_document" "policy_document_1" {
  provider = aws.account2
  statement {
    sid    = "Allow Account2 IamRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.role_sftp.arn}"]
    }
    # actions = [
    #   "s3:PutObject",
    #   "s3:GetObject",
    #   "s3:ListBucket"
    # ]
    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.bucket_1.arn}",
      "${aws_s3_bucket.bucket_1.arn}/*"
    ]
  }
}

# ACL
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls_1" {
  bucket   = aws_s3_bucket.bucket_1.bucket
  provider = aws.account2

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# SFTPアクセス先S3
resource "aws_s3_bucket" "bucket_2" {
  provider      = aws.account2
  bucket_prefix = "s3-${var.project}-${var.account1}-2"
  force_destroy = true
}

# bucket policy
resource "aws_s3_bucket_policy" "bucket_2" {
  provider = aws.account2
  bucket   = aws_s3_bucket.bucket_2.id
  policy   = data.aws_iam_policy_document.policy_document_2.json
}

data "aws_iam_policy_document" "policy_document_2" {
  provider = aws.account2
  statement {
    sid    = "Allow Account2 IamRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.role_sftp.arn}"]
    }
    # actions = [
    #   "s3:PutObject",
    #   "s3:GetObject",
    #   "s3:ListBucket"
    # ]
    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.bucket_2.arn}",
      "${aws_s3_bucket.bucket_2.arn}/*"
    ]
  }
}

# ACL
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls_2" {
  bucket   = aws_s3_bucket.bucket_2.bucket
  provider = aws.account2

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}