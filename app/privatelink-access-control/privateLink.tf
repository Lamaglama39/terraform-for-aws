##############################################################################################
# 接続元VPC (アカウントA)
##############################################################################################

## VPCエンドポイント
resource "aws_vpc_endpoint" "privateLink" {
  provider          = aws.account1
  vpc_id            = aws_vpc.vpc_b.id
  service_name      = aws_vpc_endpoint_service.vpc_endpoint_service_1.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet_b.id]

  security_group_ids = [
    aws_security_group.sg_vpcendpoint_1.id,
  ]

  depends_on = [
    aws_vpc_endpoint_service_allowed_principal.allowed_principal
  ]
}


##############################################################################################
# 接続先VPC (アカウントB)
##############################################################################################

## 接続先NLB
resource "aws_lb" "nlb-1" {
  provider                   = aws.account2
  name                       = "${var.account2}-nlb-1"
  internal                   = true
  load_balancer_type         = "network"
  security_groups            = [aws_security_group.sg_nlb_1.id]
  enable_deletion_protection = false
  subnet_mapping {
    subnet_id            = aws_subnet.private_subnet_c.id
    private_ipv4_address = var.nlb_ip
  }


  tags = {
    Name = "${var.account2}-nlb-1"
  }
}

## リスナールール
resource "aws_lb_listener" "nlb_listener_1" {
  provider          = aws.account2
  load_balancer_arn = aws_lb.nlb-1.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group_1.arn
  }
}

## ターゲットグループ
resource "aws_lb_target_group" "nlb_target_group_1" {
  provider             = aws.account2
  name                 = "${var.account2}-nlb-target-group-1"
  port                 = "80"
  protocol             = "TCP"
  vpc_id               = aws_vpc.vpc_c.id
  deregistration_delay = 180

  health_check {
    interval            = 30
    port                = "80"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

## ターゲットグループ アタッチ
resource "aws_lb_target_group_attachment" "tg_1" {
  provider         = aws.account2
  target_group_arn = aws_lb_target_group.nlb_target_group_1.arn
  target_id        = aws_instance.ec2_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_2" {
  provider         = aws.account2
  target_group_arn = aws_lb_target_group.nlb_target_group_1.arn
  target_id        = aws_instance.ec2_server_2.id
  port             = 80
}

## VPCエンドポイントサービス
resource "aws_vpc_endpoint_service" "vpc_endpoint_service_1" {
  provider                   = aws.account2
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.nlb-1.arn]
}

data "aws_caller_identity" "current" {}

resource "aws_vpc_endpoint_service_allowed_principal" "allowed_principal" {
  provider                = aws.account2
  vpc_endpoint_service_id = aws_vpc_endpoint_service.vpc_endpoint_service_1.id
  principal_arn           = "arn:aws:iam::${data.aws_caller_identity.account1_id.account_id}:root"
}
