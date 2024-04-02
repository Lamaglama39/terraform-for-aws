#debian 11 最新AMI
data "aws_ami" "debian_11" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["debian-11-amd64-*"]
  }
}

# honeypot server
resource "aws_instance" "server" {
  ami                         = data.aws_ami.debian_11.id
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.systems_manager.name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = ["${aws_security_group.server.id}"]
  associate_public_ip_address = true
  user_data                   = templatefile("./conf/cloud-config.yml", { timezone = var.timezone, password = var.linux_password, tpot_flavor = var.tpot_flavor, web_user = var.web_user, web_password = var.web_password })

  # EBS最適化を有効
  ebs_optimized = "true"

  # EBSのルートボリューム設定
  root_block_device {
    # ボリュームサイズ(GiB)
    volume_size = 150
    # ボリュームタイプ
    volume_type = "gp3"
    # # GP3のIOPS
    iops = 3000
    # # GP3のスループット
    throughput = 125
    # EC2終了時に削除
    delete_on_termination = true
    # EBSのNameタグ
    tags = {
      Name = "${var.name}-ebs"
    }
  }

  tags = {
    Name = "${var.name}-server"
  }
}

# パブリックIP
resource "aws_eip" "eip" {
  instance = aws_instance.server.id
  vpc      = true
}