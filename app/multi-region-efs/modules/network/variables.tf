variable "app_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_azs" {
  type = list(string)
}

variable "public_subnet_cidr_block" {
  type = list(string)
}

variable "private_subnet_cidr_block" {
  type = list(string)
}
