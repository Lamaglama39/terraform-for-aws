# ssh key 作成
variable "key_name" {
  type        = string
  description = "ansible-key"
  default     = "ansible-key"
}

locals {
  public_key_file  = "./.key_pair/${var.key_name}.id_rsa.pub"
  private_key_file = "./.key_pair/${var.key_name}.id_rsa"
}

resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_openssh" {
  filename = local.public_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

# aws key pair 作成
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.keygen.public_key_openssh
}

# ssh key 送信
resource "local_file" "put_private_key_server" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} ${local.private_key_file} ec2-user@${aws_instance.server.public_ip}:/home/ec2-user/.ssh"
  }
  depends_on = [aws_instance.client_1c]
}

resource "local_file" "put_public_key_server" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} ${local.public_key_file} ec2-user@${aws_instance.server.public_ip}:/home/ec2-user/.ssh"
  }
  depends_on = [aws_instance.client_1c]
}

# ansible 設定ファイル 送信
resource "local_file" "config_ansible" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -r -i ${local.private_key_file} ./conf/ansible ec2-user@${aws_instance.server.public_ip}:/home/ec2-user/"
  }
  depends_on = [aws_instance.client_1c]
}

# ssh 設定ファイル 送信
resource "local_file" "config_ssh" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -r -i ${local.private_key_file} ./conf/.ssh ec2-user@${aws_instance.server.public_ip}:/home/ec2-user/"
  }
  depends_on = [aws_instance.client_1c]
}