data "aws_ami" "debian_11" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["debian-11-amd64-*"]
  }
}

data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  region      = "ap-northeast-1"
  default_tag = "terraform"
  app_name    = "honeypot-for-ec2"
  timezone = "Asia/Tokyo"

  vpc_cidr_block           = "10.0.0.0/16"
  public_subnet_cidr_block = ["10.0.1.0/24"]
  subnet_azs               = ["ap-northeast-1a"]

  key_algorithm    = "ED25519"
  public_key_file  = "${path.root}/.key_pair/${local.app_name}.pub"
  private_key_file = "${path.root}/.key_pair/${local.app_name}"

  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = ["${local.current-ip}/32"]

  security_groups = {
    public = {
      name        = "public"
      description = "public"
      ingress_cidr_blocks = local.allowed-cidr
      ingress_with_cidr_blocks = [
        {
        from_port   = 0
        to_port     = 64000
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port   = 0
          to_port     = 64000
          protocol    = "udp"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port   = 64294
          to_port     = 64294
          protocol    = "tcp"
        },
        {
          from_port   = 64295
          to_port     = 64295
          protocol    = "tcp"
        },
        {
          from_port   = 64297
          to_port     = 64297
          protocol    = "tcp"
          },
      ],
      egress_cidr_blocks = ["0.0.0.0/0"]
      egress_with_cidr_blocks = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
      }]
    }
  }

  security_groups_map = {
    for idx, security_group in local.security_groups :
    tostring(idx) => security_group
  }

  server_instances_list = [
    {
      name                        = "server_1"
      instance_type               = "t3.xlarge"
      ami                         = data.aws_ami.debian_11.id
      associate_public_ip_address = true
      user_data                   = templatefile("./conf/cloud-config.yml", { timezone = local.timezone, password = var.linux_password, tpot_flavor = var.tpot_flavor, web_user = var.web_user, web_password = var.web_password })
    }
  ]

  server_instances_map = {
    for idx, server in local.server_instances_list :
    tostring(idx) => server
  }
}
