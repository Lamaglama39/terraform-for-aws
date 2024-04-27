terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = ">= 4.29.0"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      env = "terraform"
      app = local.app_name
    }
  }
}
