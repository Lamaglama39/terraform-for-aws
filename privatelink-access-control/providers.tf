terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
  }
}

# アカウント1用のプロバイダー
provider "aws" {
  alias   = "account1"
  region  = "ap-northeast-1"
  profile = "account1"
}

data "aws_caller_identity" "account1_id" {
  provider = "aws.account1"
}

# アカウント2用のプロバイダー
provider "aws" {
  alias   = "account2"
  region  = "ap-northeast-1"
  profile = "account2"
}
