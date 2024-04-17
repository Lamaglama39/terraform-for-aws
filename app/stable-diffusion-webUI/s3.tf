resource "aws_s3_bucket" "s3" {
  tags = {
    Name = "${var.name}-s3"
  }
}