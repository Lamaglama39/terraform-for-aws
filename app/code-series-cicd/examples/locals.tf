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
  app_name        = "code-series-cicd"
  build_bucket    = "${local.app_name}-build-artifact"
  pipeline_bucket = "${local.app_name}-pipeline"

  default_branch = "main"
  ec2_tag_filter = {
    key   = "app"
    type  = "KEY_AND_VALUE"
    value = "${local.app_name}"
  }

  vpc_cidr_block           = "10.0.0.0/16"
  public_subnet_cidr_block = ["10.0.1.0/24"]
  subnet_azs               = ["ap-northeast-1a"]

  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = ["${local.current-ip}/32"]

  security_groups = {
    public = {
      name                = "public"
      description         = "public"
      ingress_cidr_blocks = ["0.0.0.0/0"]
      ingress_with_cidr_blocks = {
        from_port   = 80
        to_port     = 80
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
    }
  }

  security_groups_map = {
    for idx, security_group in local.security_groups :
    tostring(idx) => security_group
  }

  server_instances_list = [
    {
      name                        = "web_1"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = true
      user_data                   = file("${path.root}/userdata.sh")
    }
  ]

  server_instances_map = {
    for idx, server in local.server_instances_list :
    tostring(idx) => server
  }
}
