#amazonlinux 2023 最新AMI
data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

##############################################################################################
# BucketPolicyパターン
##############################################################################################
resource "aws_instance" "ec2_1" {
  provider                    = aws.account1
  ami                         = data.aws_ami.amazonlinux_2023.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile_1.name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = true
  user_data = file("./config/cloud-config.cfg")

  tags = {
    Name = "${var.account1}-ec2-BucketPolicy"
  }

}

##############################################################################################
# AssumeRoleパターン
##############################################################################################
resource "aws_instance" "ec2_2" {
  provider                    = aws.account1
  ami                         = data.aws_ami.amazonlinux_2023.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile_2.name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = true
  user_data = file("./config/cloud-config.cfg")

  tags = {
    Name = "${var.account1}-ec2-AssumeRole"
  }
}