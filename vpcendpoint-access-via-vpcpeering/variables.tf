###############################
# provider設定

## クライアント側 アカウント
variable "account1" {
  type    = string
  default = "account1"
}

## サービス提供側 アカウント
variable "account2" {
  type    = string
  default = "account2"
}

###############################
# クライアント側 VPCピアリング経由

## VPC CIDR
variable "vpc_cidr_1" {
  type    = string
  default = "10.1.0.0/16"
}

## Subnet CDIR パブリック (EC2)
variable "subnet_cidr_public_1" {
  type    = string
  default = "10.1.0.0/24"
}

###############################
# クライアント側 VPCエンドポイント

## VPC CIDR
variable "vpc_cidr_2" {
  type    = string
  default = "10.2.0.0/16"
}

## Subnet CDIR プライベート (VPCエンドポイント)
variable "subnet_cidr_private_2" {
  type    = string
  default = "10.2.0.0/24"
}

## Subnet CDIR パブリック (EC2)
variable "subnet_cidr_public_2" {
  type    = string
  default = "10.2.1.0/24"
}

###############################
# サービス提供側

variable "vpc_cidr_3" {
  type    = string
  default = "10.3.0.0/16"
}

# Subnet CDIR プライベート (NLB)
variable "subnet_cidr_private_3" {
  type    = string
  default = "10.3.0.0/24"
}

# Subnet CDIR パブリック (EC2)
variable "subnet_cidr_public_3" {
  type    = string
  default = "10.3.1.0/24"
}

# NLB IP
variable "nlb_ip" {
  type    = string
  default = "10.3.0.100"
}

###############################
