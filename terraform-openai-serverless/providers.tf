terraform {
  required_version = ">= 1.3.0"
}

terraform {
  required_providers {
    aws = ">= 4.9.0"
  }
}
provider "aws" {
  region = "ap-northeast-1"
}