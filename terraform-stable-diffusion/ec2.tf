#AMI
data "aws_ami" "deep_learning_ami" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"

    values = [ "Deep Learning AMI GPU PyTorch 1.13.1 (Amazon Linux 2)*" ]
  }
}

# stable diffusion server
resource "aws_instance" "server" {
  ami           = data.aws_ami.deep_learning_ami.id
  instance_type = var.ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.systems_manager.name
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = ["${aws_security_group.server.id}"]
  associate_public_ip_address = true
  key_name               = aws_key_pair.key_pair.id
  user_data = file("./conf/userdata.sh")
  ebs_optimized = "true"

    # EBS ルートボリューム設定
    root_block_device {
        volume_size = 100
        volume_type = "gp3"
        iops = 3000
        throughput = 125
        delete_on_termination = true
        tags = {
            Name = "${var.name}-ebs"
        }
    }

  tags = {
    Name = "${var.name}-server"
  }
}

# eip
resource "aws_eip" "eip" {
  instance = aws_instance.server.id
  vpc = true
}


# ssh key
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

# aws key pair
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.keygen.public_key_openssh
}