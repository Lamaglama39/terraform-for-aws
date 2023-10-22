# アカウント1用EC2のセキュリティーグループ
resource "aws_security_group" "sg" {
  provider    = aws.account1
  name        = "${var.account1}-sg"
  description = "${var.account1}-sg"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.account1}-sg"
  }
}