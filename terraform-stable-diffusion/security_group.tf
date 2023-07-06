# terraform 実行元パブリックIPアドレス
data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = "${local.current-ip}/32"
}

# stable diffusion sg
resource "aws_security_group" "server" {
  name        = "${var.name}-server-sg"
  description = "${var.name}-server-sg"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-server-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed-cidr]
  }
  ingress {
    from_port   = 7860
    to_port     = 7860
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