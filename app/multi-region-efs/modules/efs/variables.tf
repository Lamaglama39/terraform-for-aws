variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "encrypted" {
  type    = bool
  default = true
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "transition_to_ia" {
  type    = string
  default = "AFTER_30_DAYS"
}

variable "subnet_id" {
  type = string
}

variable "security_groups" {
  type = set(string)
}
