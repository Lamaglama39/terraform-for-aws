terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
  }
}

# アカウント1用のプロバイダー
provider "aws" {
  alias   = "account1"
  region  = "ap-northeast-1"
  profile = "account1"
}

# アカウント2用のプロバイダー
provider "aws" {
  alias   = "account2"
  region  = "ap-northeast-1"
  profile = "account2"
}
