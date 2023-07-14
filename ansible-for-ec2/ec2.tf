#amazonlinux 2023 最新AMI
data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"

    values = [ "al2023-ami-*-kernel-6.1-x86_64" ]
  }
}

# ansible server
resource "aws_instance" "server" {
  ami           = data.aws_ami.amazonlinux_2023.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.systems_manager.name
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = ["${aws_security_group.server.id}"]
  key_name               = aws_key_pair.key_pair.id
  associate_public_ip_address = true
  user_data = file("./conf/user_data.sh")

  tags = {
    Name = "${var.name}-server"
  }
}

# ansible client
resource "aws_instance" "client_1a" {
  ami           = data.aws_ami.amazonlinux_2023.id
  instance_type = "t3.micro"
  subnet_id            = aws_subnet.private_1a.id
  vpc_security_group_ids = ["${aws_security_group.client.id}"]
  key_name               = aws_key_pair.key_pair.id

  tags = {
    Name = "${var.name}-client-1a",
    doc = "web"
  }
}

resource "aws_instance" "client_1c" {
  ami           = data.aws_ami.amazonlinux_2023.id
  instance_type = "t3.micro"
  subnet_id            = aws_subnet.private_1a.id
  vpc_security_group_ids = ["${aws_security_group.client.id}"]
  key_name               = aws_key_pair.key_pair.id

  tags = {
    Name = "${var.name}-client-1c",
    doc = "batch"
  }
}