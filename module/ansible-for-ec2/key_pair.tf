# ssh key 作成
variable "key_name" {
  type        = string
  description = "ansible-key"
  default     = "ansible-key"
}

locals {
  public_key_file  = "${path.root}/.key_pair/${var.key_name}.pem.pub"
  private_key_file = "${path.root}/.key_pair/${var.key_name}.pem"
}

resource "tls_private_key" "keygen" {
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  filename        = local.private_key_file
  content         = tls_private_key.keygen.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_key_openssh" {
  filename        = local.public_key_file
  content         = tls_private_key.keygen.public_key_openssh
  file_permission = "0600"
}

# aws key pair 作成
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.keygen.public_key_openssh
}

# ssh key 送信
resource "local_file" "put_private_key_server" {
  for_each = var.server_instances
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} ${local.private_key_file} ec2-user@${aws_instance.server[each.key].public_ip}:/home/ec2-user/.ssh"
  }
  depends_on = [aws_instance.server]
}

resource "local_file" "put_public_key_server" {
  for_each = var.server_instances
  filename = local.private_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} ${local.public_key_file} ec2-user@${aws_instance.server[each.key].public_ip}:/home/ec2-user/.ssh"
  }
  depends_on = [aws_instance.server]
}

# ansible 設定ファイル 送信
resource "local_file" "config_ansible" {
  for_each = var.server_instances
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -r -i ${local.private_key_file} ${path.module}/conf/ansible ec2-user@${aws_instance.server[each.key].public_ip}:/home/ec2-user/"
  }
  depends_on = [aws_instance.server]
}

# ssh 設定ファイル 送信
resource "local_file" "config_ssh" {
  for_each = var.server_instances
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -r -i ${local.private_key_file} ${path.module}/conf/.ssh ec2-user@${aws_instance.server[each.key].public_ip}:/home/ec2-user/"
  }
  depends_on = [aws_instance.server]
}
