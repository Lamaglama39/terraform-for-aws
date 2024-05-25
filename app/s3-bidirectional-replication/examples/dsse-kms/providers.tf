terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = ">= 4.0.0"
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

provider "aws" {
  alias  = "secondary"
  region = "ap-northeast-3"
  default_tags {
    tags = {
      env = "terraform"
      app = local.app_name
    }
  }
}
