#debian 11 最新AMI
data "aws_ami" "debian_11" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"

    values = [ "debian-11-amd64-*" ]
  }
}

# honeypot server
resource "aws_instance" "server" {
  ami           = data.aws_ami.debian_11.id
  instance_type = "t3.xlarge"
  iam_instance_profile = aws_iam_instance_profile.systems_manager.name
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = ["${aws_security_group.server.id}"]
  # key_name               = aws_key_pair.key_pair.id
  associate_public_ip_address = true
  user_data = file("./conf/user_data.sh")

    # EBS最適化を有効
    ebs_optimized = "true"

    # EBSのルートボリューム設定
    root_block_device {
        # ボリュームサイズ(GiB)
        volume_size = 300
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