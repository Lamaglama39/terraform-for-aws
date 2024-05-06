variable "app_name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "multi_az" {
  type = bool
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "manage_master_user_password" {
  type = bool
}

variable "password" {
  type = string
}

variable "port" {
  type = number
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "deletion_protection" {
  type = bool
}

variable "pg_family" {
  type = string
}

variable "og_major_engine_version" {
  type = string
}

variable "parameters" {
  type = any
}

variable "options" {
  type = any
}
