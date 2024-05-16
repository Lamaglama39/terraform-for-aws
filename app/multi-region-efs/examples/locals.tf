data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"

    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

data "aws_ami" "amazonlinux_2023_replica" {
  provider    = aws.replica
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

data "template_file" "user_data" {
  template = file("./conf/userdata.sh")
  vars = {
    file_system_id = module.efs.efs.id
  }
}

data "template_file" "user_data_replica" {
  template = file("./conf/userdata.sh")
  vars = {
    file_system_id = module.efs_secondary.efs.id
  }
}

locals {
  app_name     = "multi-region-efs"
  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = "${local.current-ip}/32"

  # network
  vpc_region1 = {
    region                    = "ap-northeast-1"
    vpc_cidr_block            = "10.0.0.0/16"
    subnet_azs                = ["ap-northeast-1a"]
    public_subnet_cidr_block  = ["10.0.0.0/24"]
    private_subnet_cidr_block = ["10.0.1.0/24"]
  }
  vpc_region2 = {
    region                    = "ap-northeast-3"
    vpc_cidr_block            = "10.1.0.0/16"
    subnet_azs                = ["ap-northeast-3a"]
    public_subnet_cidr_block  = ["10.1.0.0/24"]
    private_subnet_cidr_block = ["10.1.1.0/24"]
  }

  # iam
  trusted_role_services = ["ec2.amazonaws.com"]
  instance_iam_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess",
  ]

  # security group
  security_groups = {
    ec2 = {
      name        = "ec2"
      description = "ec2"
    },
    efs = {
      name        = "efs"
      description = "efs"
    }
  }

  # sg rules
  sg_rules = {
    ec2 = {
      security_group_id = module.sg.ec2.sg.id
      rule = [
        {
          type        = "ingress"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [local.allowed-cidr]
        },
        {
          type        = "egress"
          from_port   = 0
          to_port     = 65535
          protocol    = -1
          cidr_blocks = ["0.0.0.0/0"]
        },
      ]
    },
    efs = {
      security_group_id = module.sg.efs.sg.id
      rule = [
        {
          type                     = "ingress"
          from_port                = 2049
          to_port                  = 2049
          protocol                 = "tcp"
          source_security_group_id = module.sg.ec2.sg.id
        },
        {
          type        = "egress"
          from_port   = 0
          to_port     = 65535
          protocol    = -1
          cidr_blocks = ["0.0.0.0/0"]
        },
      ]
    },
  }

  sg_rules_replica = {
    ec2 = {
      security_group_id = module.sg_replica.ec2.sg.id
      rule = [
        {
          type        = "ingress"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [local.allowed-cidr]
        },
        {
          type        = "egress"
          from_port   = 0
          to_port     = 65535
          protocol    = -1
          cidr_blocks = ["0.0.0.0/0"]
        },
      ]
    },
    efs = {
      security_group_id = module.sg_replica.efs.sg.id
      rule = [
        {
          type                     = "ingress"
          from_port                = 2049
          to_port                  = 2049
          protocol                 = "tcp"
          source_security_group_id = module.sg_replica.ec2.sg.id
        },
        {
          type        = "egress"
          from_port   = 0
          to_port     = 65535
          protocol    = -1
          cidr_blocks = ["0.0.0.0/0"]
        },
      ]
    },
  }

  # ec2
  key_algorithm            = "ED25519"
  private_key_file         = "${path.root}/.key_pair/${local.app_name}"
  private_key_file_replica = "${path.root}/.key_pair/${local.app_name}-replica"

  server_instances = {
    web = {
      name                        = "web"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = true
      user_data                   = "${data.template_file.user_data.rendered}"
    }
  }

  server_instances_replica = {
    web = {
      name                        = "web"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023_replica.id
      associate_public_ip_address = true
      user_data                   = "${data.template_file.user_data_replica.rendered}"
    }
  }

  # efs
  primary_region   = "ap-northeast-1"
  secondary_region = "ap-northeast-3"
}
