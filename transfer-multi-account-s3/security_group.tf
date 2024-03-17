# terraform 実行元のパブリックIPアドレス
data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = "${local.current-ip}/32"
}

# クライアントEC2用セキュリティグループ
resource "aws_security_group" "client" {
  name        = "${var.project}-client-sg"
  description = "${var.project}-client-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-client-sg"
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

# SFTPサーバ用セキュリティグループ
resource "aws_security_group" "server" {
  name        = "${var.project}-sftp-sg"
  description = "${var.project}-sftp-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-sftp-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
