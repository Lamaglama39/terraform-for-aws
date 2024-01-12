# amazonlinux 2023 (共通AMI)
data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

##############################################################################################
# 接続元EC2
##############################################################################################
resource "aws_instance" "ec2_1" {
  provider                    = aws.account1
  ami                         = data.aws_ami.amazonlinux_2023.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile_1.name
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = ["${aws_security_group.sg_ec2_1.id}"]
  associate_public_ip_address = true
  user_data = file("./config/cloud-config-client.cfg")

  tags = {
    Name = "${var.account1}-ec2-1"
  }
}

##############################################################################################
# 接続先EC2
##############################################################################################
resource "aws_instance" "ec2_2" {
  provider                    = aws.account2
  ami                         = data.aws_ami.amazonlinux_2023.id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile_2.name
  subnet_id                   = aws_subnet.public_subnet_c.id
  vpc_security_group_ids      = ["${aws_security_group.sg_ec2_2.id}"]
  associate_public_ip_address = true
  user_data = file("./config/cloud-config-web-server.cfg")

  tags = {
    Name = "${var.account2}-ec2-2"
  }
}