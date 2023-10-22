##############################################################################################
# BucketPolicyパターン
##############################################################################################
# アカウント1用のS3
resource "aws_s3_bucket" "bucket1" {
  provider      = aws.account1
  bucket_prefix = "s3-${var.account1}-bucketpolicy-"
  force_destroy = true
}

# ACL
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls1" {
  bucket   = aws_s3_bucket.bucket1.bucket
  provider = aws.account1

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# アカウント2用のS3
resource "aws_s3_bucket" "bucket2" {
  provider      = aws.account2
  bucket_prefix = "s3-${var.account2}-bucketpolicy-"
  force_destroy = true
}

# bucket policy
resource "aws_s3_bucket_policy" "bucket2" {
  provider = aws.account2
  bucket   = aws_s3_bucket.bucket2.id
  policy   = data.aws_iam_policy_document.policy_document2.json
}

data "aws_iam_policy_document" "policy_document2" {
  provider = aws.account2
  statement {
    sid    = "Allow Account1 IamRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.ec2_role_1.arn}"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.bucket2.arn}",
      "${aws_s3_bucket.bucket2.arn}/*"
    ]
  }
}

#ACL
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls2" {
  bucket   = aws_s3_bucket.bucket2.bucket
  provider = aws.account2

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

##############################################################################################
# AssumeRoleパターン
##############################################################################################
# アカウント1用のS3
resource "aws_s3_bucket" "bucket3" {
  provider      = aws.account1
  bucket_prefix = "s3-${var.account1}-assumerole-"
  force_destroy = true
}

# bucket policy
resource "aws_s3_bucket_policy" "bucket3" {
  provider = aws.account1
  bucket   = aws_s3_bucket.bucket3.id
  policy   = data.aws_iam_policy_document.policy_document3.json
}

data "aws_iam_policy_document" "policy_document3" {
  provider = aws.account2
  statement {
    sid    = "Allow Account2 IamRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.ec2_role_3.arn}"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.bucket3.arn}",
      "${aws_s3_bucket.bucket3.arn}/*"
    ]
  }
}

# ACL
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls3" {
  bucket   = aws_s3_bucket.bucket3.bucket
  provider = aws.account1

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# アカウント2用のS3
resource "aws_s3_bucket" "bucket4" {
  provider      = aws.account2
  bucket_prefix = "s3-${var.account2}-assumerole-"
  force_destroy = true
}

#ACL
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls4" {
  bucket   = aws_s3_bucket.bucket2.bucket
  provider = aws.account2

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}