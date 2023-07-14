# Session Manager用 IAMロール
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.name}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "ec2_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}
resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.ec2_full_access.arn
}

resource "aws_iam_instance_profile" "systems_manager" {
  name = "${var.name}-ssm-instanceProfile"
  role = aws_iam_role.role.name
}