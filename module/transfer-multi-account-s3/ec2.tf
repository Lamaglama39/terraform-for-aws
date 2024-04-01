#amazonlinux 2023 最新AMI
data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

# クライアント用EC2
resource "aws_instance" "client" {
  ami                         = data.aws_ami.amazonlinux_2023.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.systems_manager.name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.client.id}"]
  key_name                    = aws_key_pair.key_pair.id
  associate_public_ip_address = true
  user_data = file("./conf/user_data.sh")

  tags = {
    Name = "${var.project}-ec2-client"
  }
}

# Session Manager用 IAMロール
data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role_ec2" {
  name               = "${var.project}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.role_ec2.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

resource "aws_iam_instance_profile" "systems_manager" {
  name = "${var.project}-ssm-instanceProfile"
  role = aws_iam_role.role_ec2.name
}
