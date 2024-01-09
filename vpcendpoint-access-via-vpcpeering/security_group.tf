##############################################################################################
# 接続元EC2 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_ec2_1" {
  provider    = aws.account1
  name        = "${var.account1}-sg-ec2-1"
  description = "${var.account1}-sg-ec2-1"
  vpc_id      = aws_vpc.vpc_a.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.vpc_a.cidr_block}"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.vpc_b.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.account1}-sg-vpcendpoint-1"
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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