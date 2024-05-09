resource "aws_security_group" "this" {
  name        = "${var.app_name}-${var.security_groups.name}-sg"
  description = var.security_groups.description
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.app_name}-${var.security_groups.name}-sg"
  }
}
