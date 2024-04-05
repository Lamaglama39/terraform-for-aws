terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = ">= 4.29.0"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      env = var.default_tag
    }
  }
}
