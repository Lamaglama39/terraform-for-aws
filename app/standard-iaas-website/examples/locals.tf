data "aws_ami" "amazonlinux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

data "template_file" "user_data" {
  template = file("./conf/userdata.sh")
  vars = {
    db_name    = "${local.db_name}"
    db_user    = "${local.username}"
    db_pass    = "${var.rds_password}"
    db_host    = "${module.rds.rds.db_instance_address}"
    site_title = "${local.site_title}"
    admin_user = "${local.wp_admin_user}"
    admin_pass = "${var.wp_password}"
    email      = "${var.email}"
  }
}

data "http" "ipv4_icanhazip" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  app_name     = "standard-website"
  current-ip   = chomp(data.http.ipv4_icanhazip.body)
  allowed-cidr = "${local.current-ip}/32"

  # wordpress
  site_title    = "test-site"
  wp_admin_user = "wp_admin_user"

  # network
  vpc_cidr_block            = "10.0.0.0/16"
  subnet_azs                = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnet_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidr_block = ["10.0.10.0/24", "10.0.11.0/24"]

  # iam
  trusted_role_services = ["ec2.amazonaws.com"]
  instance_iam_policy_arns = [
    "arn:aws:iam::aws:policy/PowerUserAccess",
  ]

  # security group
  security_groups = {
    nlb = {
      name        = "nlb"
      description = "nlb"
    },
    alb = {
      name        = "alb"
      description = "alb"
    },
    ec2 = {
      name        = "ec2"
      description = "ec2"
    },
    rds = {
      name        = "rds"
      description = "rds"
    }
  }

  # ingress rule
  sg_rules = {
    nlb = {
      security_group_id = module.sg.nlb.sg.id
      rule = [
        {
          type        = "ingress"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          type                     = "egress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          source_security_group_id = module.sg.alb.sg.id
        },
      ]
    },
    alb = {
      security_group_id = module.sg.alb.sg.id
      rule = [
        {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          source_security_group_id = module.sg.nlb.sg.id
        },
        {
          type                     = "egress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          source_security_group_id = module.sg.ec2.sg.id
        },
      ]
    },
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
          type        = "ingress"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = [local.allowed-cidr]
        },
        {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          source_security_group_id = module.sg.alb.sg.id
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
    rds = {
      security_group_id = module.sg.rds.sg.id
      rule = [
        {
          type                     = "ingress"
          from_port                = 3306
          to_port                  = 3306
          protocol                 = "tcp"
          source_security_group_id = module.sg.ec2.sg.id
        },
      ]
    },
  }

  # ec2
  key_algorithm    = "ED25519"
  private_key_file = "${path.root}/.key_pair/${local.app_name}"

  server_instances = {
    web = {
      name                        = "web"
      instance_type               = "t2.micro"
      ami                         = data.aws_ami.amazonlinux_2023.id
      associate_public_ip_address = true
      user_data                   = "${data.template_file.user_data.rendered}"
    }
  }

  # rds
  engine              = "mysql"
  engine_version      = "8.0.39"
  instance_class      = "db.t3.large"
  allocated_storage   = 20
  multi_az            = true
  deletion_protection = false

  db_name  = "demodb"
  username = "mysql_admin_user"
  port     = "3306"


  pg_family               = "mysql8.0"
  og_major_engine_version = "8.0"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
