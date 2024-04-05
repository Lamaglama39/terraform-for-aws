variable "default_tag" {
  type = string
}

variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_cidr_block" {
  type = string
}

variable "private_subnet_cidr_block" {
  type = string
}

variable "public_subnet_az" {
  type = string
}

variable "private_subnet_az" {
  type = string
}


variable "instance_type" {
  type = string
}

variable "server_instances" {
  type = map(any)
}

variable "client_instances" {
  type = map(any)
}

