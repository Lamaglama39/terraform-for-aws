#amazonlinux 2023 最新AMI
data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

# ansible server
resource "aws_instance" "server" {
  for_each                    = var.server_instances
  ami                         = data.aws_ami.amazonlinux_2023.id
  instance_type               = each.value.instance_type
  iam_instance_profile        = aws_iam_instance_profile.systems_manager.name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.server.id}"]
  key_name                    = aws_key_pair.key_pair.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/conf/user_data.sh")
  tags                        = each.value.tags
}

# ansible client
resource "aws_instance" "client_1a" {
  for_each               = var.client_instances
  ami                    = data.aws_ami.amazonlinux_2023.id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = ["${aws_security_group.client.id}"]
  key_name               = aws_key_pair.key_pair.id
  tags                   = each.value.tags
}
