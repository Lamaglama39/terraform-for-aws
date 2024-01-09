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
# 接続元EC2 IAMロール
##############################################################################################

# EC2 IAMロール
resource "aws_iam_role" "ec2_role_1" {
  provider           = aws.account1
  name               = "${var.account1}-ec2-role-1"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# EC2 IAMポリシーアタッチ
resource "aws_iam_role_policy_attachment" "ssm_1" {
  provider   = aws.account1
  role       = aws_iam_role.ec2_role_1.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

# EC2 インスタンスプロファイル
resource "aws_iam_instance_profile" "ec2_instance_profile_1" {
  provider = aws.account1
  name     = "${var.account1}-instanceProfile-1"
  role     = aws_iam_role.ec2_role_1.name
}

##############################################################################################
# 接続先EC2 IAMロール
##############################################################################################

# EC2 IAMロール
resource "aws_iam_role" "ec2_role_2" {
  provider           = aws.account2
  name               = "${var.account2}-ec2-role-2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# EC2 IAMポリシーアタッチ
resource "aws_iam_role_policy_attachment" "ssm_2" {
  provider   = aws.account2
  role       = aws_iam_role.ec2_role_2.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

# EC2 インスタンスプロファイル
resource "aws_iam_instance_profile" "ec2_instance_profile_2" {
  provider = aws.account2
  name     = "${var.account2}-instanceProfile-2"
  role     = aws_iam_role.ec2_role_2.name
}