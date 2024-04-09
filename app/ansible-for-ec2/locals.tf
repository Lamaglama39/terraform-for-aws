data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  region      = "ap-northeast-1"
  default_tag = "terraform"
  app_name    = "ansible-for-ec2"

  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr_block = ["10.0.11.0/24", "10.0.21.0/24"]
  subnet_azs                = ["ap-northeast-1a", "ap-northeast-1c"]

  key_algorithm    = "ED25519"
  public_key_file  = "${path.root}/.key_pair/${local.app_name}.pub"
  private_key_file = "${path.root}/.key_pair/${local.app_name}"

  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = ["${local.current-ip}/32"]

  security_groups = {
    public = {
      name                = "public"
      description         = "public"
      ingress_cidr_blocks = local.allowed-cidr
      ingress_with_cidr_blocks = {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "public"
      },
      egress_cidr_blocks = ["0.0.0.0/0"]
      egress_with_cidr_blocks = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "public"
      },
    },
    private = {
      name                = "private"
      description         = "private"
      ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
      ingress_with_cidr_blocks = {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "private"
      },
      egress_cidr_blocks = ["0.0.0.0/0"]
      egress_with_cidr_blocks = {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "public"
      },
    }
  }

  security_groups_map = {
    for idx, security_group in local.security_groups :
    tostring(idx) => security_group
  }

  server_instances_list = [
    {
      name                        = "server_1"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = true
      user_data                   = file("${path.module}/conf/userdata/server.sh")
    },
    {
      name                        = "server_2"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = true
      user_data                   = file("${path.module}/conf/userdata/server.sh")
    }
  ]

  server_instances_map = {
    for idx, server in local.server_instances_list :
    tostring(idx) => server
  }

  client_instances_list = [
    {
      name                        = "client_1"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = false
      user_data                   = file("${path.module}/conf/userdata/client.sh")
    },
    {
      name                        = "client_2"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = false
      user_data                   = file("${path.module}/conf/userdata/client.sh")
    }
  ]

  client_instances_map = {
    for idx, client in local.client_instances_list :
    tostring(idx) => client
  }
}
