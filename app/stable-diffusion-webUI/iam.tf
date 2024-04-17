# stable diffusion用IAMロール
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
data "aws_iam_policy" "s3" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}
resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.s3.arn
}

resource "aws_iam_instance_profile" "systems_manager" {
  name = "${var.name}-ssm-instanceProfile"
  role = aws_iam_role.role.name
}

# fleet_request用 IAMロール
data "aws_iam_policy_document" "assume_role_fleet" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "spot-fleet-role" {
  name               = "${var.name}-fleet-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_fleet.json
}

resource "aws_iam_policy_attachment" "policy-attach" {
  name       = "${var.name}-fleet-attach"
  roles      = ["${aws_iam_role.spot-fleet-role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}