# terraform 実行元のパブリックIPアドレス
data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  current-ip = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr  = "${local.current-ip}/32"
}

# 管理サーバ セキュリティーグループ
resource "aws_security_group" "server" {
  name        = "${var.name}-server-sg"
  description = "${var.name}-server-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed-cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# クライアント セキュリティーグループ
resource "aws_security_group" "client" {
  name        = "${var.name}-client-sg"
  description = "${var.name}-client-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.server.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}