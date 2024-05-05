module "nlb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.app_name}-nlb"
  load_balancer_type         = "network"
  vpc_id                     = var.vpc_id
  subnets                    = var.nlb_subnet
  create_security_group      = false
  security_groups            = var.nlb_security_groups
  enable_deletion_protection = false

  listeners = {
    ex-tcp = {
      port     = 80
      protocol = "TCP"
      forward = {
        target_group_key = "ex-alb"
      }
    }
  }

  target_groups = {
    ex-alb = {
      name_prefix = "pref-"
      protocol    = "TCP"
      port        = 80
      target_type = "alb"
      target_id   = module.alb.arn
    }
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.app_name}-alb"
  load_balancer_type         = "application"
  internal                   = true
  vpc_id                     = var.vpc_id
  subnets                    = var.alb_subnet
  create_security_group      = false
  security_groups            = var.alb_security_groups
  enable_deletion_protection = false

  listeners = {
    ex-tcp = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix       = "h1"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 2
        matcher             = "200-299"
      }
    }
  }
}

# インスタンスをALBのターゲットグループに登録
resource "aws_lb_target_group_attachment" "ex_instance" {
  for_each = toset(var.instance_id)

  target_group_arn = module.alb.target_groups["ex-instance"].arn
  target_id        = each.value
  port             = 80
}
