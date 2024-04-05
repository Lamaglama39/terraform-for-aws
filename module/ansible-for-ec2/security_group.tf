# terraform 実行元のパブリックIPアドレス
data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = "${local.current-ip}/32"
}

# 管理サーバ セキュリティーグループ
resource "aws_security_group" "server" {
  name        = "${var.app_name}-server-sg"
  description = "${var.app_name}-server-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "server" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = local.allowed-cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "server" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# クライアント セキュリティーグループ
resource "aws_security_group" "client" {
  name        = "${var.app_name}-client-sg"
  description = "${var.app_name}-client-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "client" {
  security_group_id = aws_security_group.client.id
  cidr_ipv4         = aws_subnet.public.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "client" {
  security_group_id = aws_security_group.client.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
