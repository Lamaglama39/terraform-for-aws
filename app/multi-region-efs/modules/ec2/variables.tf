variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "server_instances_map" {
  type = any
}

variable "iam_role" {
  type = string
}

variable "vpc_security_group_ids" {
  type = any
}

variable "key_name" {
  type = any
}
