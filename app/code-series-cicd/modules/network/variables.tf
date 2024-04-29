variable "app_name" {
  description = "This app name"
  type        = string
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
