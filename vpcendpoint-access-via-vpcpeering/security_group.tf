##############################################################################################
# 接続元EC2 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_ec2_1" {
  provider    = aws.account1
  name        = "${var.account1}-sg-ec2-1"
  description = "${var.account1}-sg-ec2-1"
  vpc_id      = aws_vpc.vpc_a.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${aws_vpc.vpc_b.cidr_block}"]
  }

  tags = {
    Name = "${var.account1}-sg-ec2-1"
  }
}

##############################################################################################
# VPCエンドポイント用 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_vpcendpoint_1" {
  provider    = aws.account1
  name        = "${var.account1}-sg-vpcendpoint-1"
  description = "${var.account1}-sg-vpcendpoint-1"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${aws_vpc.vpc_a.cidr_block}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${aws_vpc.vpc_c.cidr_block}"]
  }

  tags = {
    Name = "${var.account1}-sg-vpcendpoint-1"
  }
}

##############################################################################################
# 接続先用NLB セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_nlb_1" {
  provider    = aws.account2
  name        = "${var.account2}-sg-nlb-1"
  description = "${var.account2}-sg-nlb-1"
  vpc_id      = aws_vpc.vpc_c.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${aws_vpc.vpc_b.cidr_block}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${aws_instance.ec2_2.private_ip}/32"]
  }
  tags = {
    Name = "${var.account2}-sg-nlb-1"
  }
}

##############################################################################################
# 接続先用EC2 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_ec2_2" {
  provider    = aws.account2
  name        = "${var.account2}-sg-ec2-2"
  description = "${var.account2}-sg-ec2-2"
  vpc_id      = aws_vpc.vpc_c.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${aws_vpc.vpc_c.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.account2}-sg-ec2-2"
  }
}