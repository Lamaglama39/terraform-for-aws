##############################################################################################
# 共通利用
##############################################################################################
# EC2 信頼ポリシー
data "aws_iam_policy_document" "assume_role" {
  provider = aws.account1
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EC2用 SMM IAMポリシー
data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


##############################################################################################
# BucketPolicyパターン
##############################################################################################

# EC2 IAMロール
resource "aws_iam_role" "ec2_role_1" {
  provider           = aws.account1
  name               = "${var.account1}-ec2-role-1"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# EC2 アカウント1 S3アクセスIAMポリシー
data "aws_iam_policy_document" "account1-s3-access_1" {
  statement {
    sid = "Account1S3Access"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.bucket1.arn}",
      "${aws_s3_bucket.bucket1.arn}/*"
    ]
  }
}

#EC2 アカウント2 S3アクセスIAMポリシー
data "aws_iam_policy_document" "account2-s3-access_1" {
  statement {
    sid = "Account2S3Access"
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

# EC2 IAMポリシー
resource "aws_iam_policy" "account1-s3-access_1" {
  provider           = aws.account1
  policy = data.aws_iam_policy_document.account1-s3-access_1.json
  name   = "${var.account1}-S3access-iam-policy-1"
}

resource "aws_iam_policy" "account2-s3-access_1" {
  provider           = aws.account1
  policy = data.aws_iam_policy_document.account2-s3-access_1.json
  name   = "${var.account2}-S3access-iam-policy-1"
}

# EC2 IAMポリシーアタッチ
resource "aws_iam_role_policy_attachment" "ssm_1" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_role_1.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

resource "aws_iam_role_policy_attachment" "account1-s3-access_1" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_role_1.name
  policy_arn = aws_iam_policy.account1-s3-access_1.arn
}

resource "aws_iam_role_policy_attachment" "account2-s3-access_1" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_role_1.name
  policy_arn = aws_iam_policy.account2-s3-access_1.arn
}

# アカウント1用EC2 インスタンスプロファイル
resource "aws_iam_instance_profile" "ec2_instance_profile_1" {
  provider = aws.account1
  name     = "${var.account1}-instanceProfile-1"
  role     = aws_iam_role.ec2_role_1.name
}

##############################################################################################
# AssumeRoleパターン
##############################################################################################

######################################
# アカウント1 EC2用IAMロール
######################################
# EC2 IAMロール
resource "aws_iam_role" "ec2_role_2" {
  provider           = aws.account1
  name               = "${var.account1}-ec2-role-2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# EC2 アカウント1 S3アクセスIAMポリシー
data "aws_iam_policy_document" "account1-s3-access_2" {
  statement {
    sid = "Account1S3Access"
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

  statement {
    sid = "Account1AssumeRole"
    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "${aws_iam_role.ec2_role_3.arn}",
    ]
  }
}

# EC2 IAMポリシー
resource "aws_iam_policy" "account1-s3-access_2" {
  provider           = aws.account1
  policy = data.aws_iam_policy_document.account1-s3-access_2.json
  name   = "${var.account1}-S3access-iam-policy-2"
}

# EC2 IAMポリシーアタッチ
resource "aws_iam_role_policy_attachment" "ssm_2" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_role_2.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

resource "aws_iam_role_policy_attachment" "account1-s3-access_2" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_role_2.name
  policy_arn = aws_iam_policy.account1-s3-access_2.arn
}

# アカウント1用EC2 インスタンスプロファイル
resource "aws_iam_instance_profile" "ec2_instance_profile_2" {
  provider = aws.account1
  name     = "${var.account1}-instanceProfile-2"
  role     = aws_iam_role.ec2_role_2.name
}





######################################
# アカウント2 AssumeRole用IAMロール
######################################
# AssumeRole 信頼ポリシー
data "aws_iam_policy_document" "assume_role_2" {
  provider = aws.account2
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.ec2_role_2.arn}"]
    }
  }
}

# AssumeRole IAMロール
resource "aws_iam_role" "ec2_role_3" {
  provider = aws.account2
  name               = "${var.account2}-ec2-role-3"
  assume_role_policy = data.aws_iam_policy_document.assume_role_2.json
}

# EC2 アカウント1 S3アクセスIAMポリシー
data "aws_iam_policy_document" "account1-s3-access_3" {
  statement {
    sid = "Account1S3Access"
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

#EC2 アカウント2 S3アクセスIAMポリシー
data "aws_iam_policy_document" "account2-s3-access_2" {
  statement {
    sid = "Account2S3Access"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.bucket4.arn}",
      "${aws_s3_bucket.bucket4.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "account1-s3-access_3" {
  provider = aws.account2
  policy = data.aws_iam_policy_document.account1-s3-access_3.json
  name   = "${var.account2}-S3access-iam-policy-3"
}

resource "aws_iam_policy" "account2-s3-access_2" {
  provider = aws.account2
  policy = data.aws_iam_policy_document.account2-s3-access_2.json
  name   = "${var.account2}-S3access-iam-policy-2"
}

resource "aws_iam_role_policy_attachment" "account1-s3-access_3" {
  provider = aws.account2
  role       = aws_iam_role.ec2_role_3.name
  policy_arn = aws_iam_policy.account1-s3-access_3.arn
}

resource "aws_iam_role_policy_attachment" "account2-s3-access_2" {
  provider = aws.account2
  role       = aws_iam_role.ec2_role_3.name
  policy_arn = aws_iam_policy.account2-s3-access_2.arn
}

