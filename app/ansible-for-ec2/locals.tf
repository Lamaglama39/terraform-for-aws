locals {
  region      = "ap-northeast-1"
  default_tag = "terraform"
  app_name    = "ansible-for-ec2"

  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_block  = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"
  public_subnet_az          = "ap-northeast-1a"
  private_subnet_az         = "ap-northeast-1a"


  instance_type = "t3.micro"

  server_instances = {
    server_1 = {
      instance_type = "t2.micro"
      tags = {
        Name = "${local.app_name}-sever"
        doc  = "manager"
      }
    }
  }

  client_instances = {
    client_1 = {
      instance_type = "t2.micro"
      tags = {
        Name = "${local.app_name}-client-1"
        doc  = "web"
      }
    },
    client_2 = {
      instance_type = "t2.micro"
      tags = {
        Name = "${local.app_name}-client-2"
        doc  = "app"
      }
    }
  }
}
