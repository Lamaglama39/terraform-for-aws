# terraform 実行元のパブリックIPアドレス
data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  current-ip = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr  = "${local.current-ip}/32"
}

# honeypot server セキュリティーグループ
resource "aws_security_group" "server" {
  name        = "${var.name}-server-sg"
  description = "${var.name}-server-sg"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-server-sg"
  }

  ingress {
    from_port   = 0
    to_port     = 64000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 64000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 64294
    to_port     = 64294
    protocol    = "tcp"
    cidr_blocks = [local.allowed-cidr]
  }
  ingress {
    from_port   = 64295
    to_port     = 64295
    protocol    = "tcp"
    cidr_blocks = [local.allowed-cidr]
  }
  ingress {
    from_port   = 64297
    to_port     = 64297
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