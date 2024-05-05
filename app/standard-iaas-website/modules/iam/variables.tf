variable "app_name" {
  type = string
}

variable "trusted_role_services" {
  type = list(string)
}

variable "instance_iam_policy_arns" {
  type = list(string)
}
