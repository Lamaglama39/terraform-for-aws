##############################################################################################
# クライアント側EC2用 VPCピアリング経由 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_ec2_client_1" {
  provider    = aws.account1
  name        = "${var.account1}-sg-ec2-client-1"
  description = "${var.account1}-sg-ec2-client-1"
  vpc_id      = aws_vpc.vpc_a.id

  tags = {
    Name = "${var.account1}-sg-ec2-client-1"
  }
}

resource "aws_security_group_rule" "egress_allow_ssm_client_1" {
  provider          = aws.account1
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2_client_1.id

  depends_on = [aws_security_group.sg_vpcendpoint_1]
}

resource "aws_security_group_rule" "egress_allow_vpcendpoint_client_1" {
  provider                 = aws.account1
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_vpcendpoint_1.id
  security_group_id        = aws_security_group.sg_ec2_client_1.id

  depends_on = [aws_security_group.sg_vpcendpoint_1]
}

##############################################################################################
# クライアント側EC2用 VPCエンドポイント セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_ec2_client_2" {
  provider    = aws.account1
  name        = "${var.account1}-sg-ec2-client-2"
  description = "${var.account1}-sg-ec2-client-2"
  vpc_id      = aws_vpc.vpc_b.id

  tags = {
    Name = "${var.account1}-sg-ec2-client-2"
  }
}

resource "aws_security_group_rule" "egress_allow_ssm_client_2" {
  provider          = aws.account1
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2_client_2.id

  depends_on = [aws_security_group.sg_vpcendpoint_1]
}

resource "aws_security_group_rule" "egress_allow_vpcendpoint_client_2" {
  provider                 = aws.account1
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_vpcendpoint_1.id
  security_group_id        = aws_security_group.sg_ec2_client_2.id

  depends_on = [aws_security_group.sg_vpcendpoint_1]
}

##############################################################################################
# クライアント側VPCエンドポイント用 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_vpcendpoint_1" {
  provider    = aws.account1
  name        = "${var.account1}-sg-vpcendpoint-1"
  description = "${var.account1}-sg-vpcendpoint-1"
  vpc_id      = aws_vpc.vpc_b.id

  tags = {
    Name = "${var.account1}-sg-vpcendpoint-1"
  }
}

resource "aws_security_group_rule" "egress_allow_ec2_1" {
  provider                 = aws.account1
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_ec2_client_1.id
  security_group_id        = aws_security_group.sg_vpcendpoint_1.id

  depends_on = [aws_security_group.sg_ec2_client_1]
}

resource "aws_security_group_rule" "egress_allow_ec2_2" {
  provider                 = aws.account1
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_ec2_client_2.id
  security_group_id        = aws_security_group.sg_vpcendpoint_1.id

  depends_on = [aws_security_group.sg_ec2_client_2]
}

##############################################################################################
# 接続先用NLB セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_nlb_1" {
  provider    = aws.account2
  name        = "${var.account2}-sg-nlb-1"
  description = "${var.account2}-sg-nlb-1"
  vpc_id      = aws_vpc.vpc_c.id

  tags = {
    Name = "${var.account2}-sg-nlb-1"
  }
}

resource "aws_security_group_rule" "egress_allow_client_1" {
  provider          = aws.account2
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["${aws_instance.ec2_client_vpcpeering.private_ip}/32"]
  security_group_id = aws_security_group.sg_nlb_1.id
}

resource "aws_security_group_rule" "egress_allow_client_2" {
  provider          = aws.account2
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["${aws_instance.ec2_client_vpcendpoint.private_ip}/32"]
  security_group_id = aws_security_group.sg_nlb_1.id
}

resource "aws_security_group_rule" "egress_allow_ec2_sg_server" {
  provider                 = aws.account2
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_ec2_server.id
  security_group_id        = aws_security_group.sg_nlb_1.id

  depends_on = [aws_security_group.sg_ec2_server]
}

##############################################################################################
# 接続先用EC2 セキュリティーグループ
##############################################################################################

resource "aws_security_group" "sg_ec2_server" {
  provider    = aws.account2
  name        = "${var.account2}-sg-ec2-server"
  description = "${var.account2}-sg-ec2-server"
  vpc_id      = aws_vpc.vpc_c.id

  tags = {
    Name = "${var.account2}-sg-ec2-server"
  }
}

resource "aws_security_group_rule" "egress_allow_nlb" {
  provider                 = aws.account2
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_nlb_1.id
  security_group_id        = aws_security_group.sg_ec2_server.id

  depends_on = [aws_security_group.sg_nlb_1]
}

resource "aws_security_group_rule" "egress_allow_ssm_server" {
  provider          = aws.account2
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2_server.id
}
