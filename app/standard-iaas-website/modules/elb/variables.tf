variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "nlb_subnet" {
  type = list(string)
}

variable "alb_subnet" {
  type = list(string)
}

variable "nlb_security_groups" {
  type = list(string)
}

variable "alb_security_groups" {
  type = list(string)
}

variable "instance_id" {
  type = list(string)
}
