variable "app_name" {
  description = "This app name"
  type        = string
}

variable "server_instances_map" {
  type = any
}

variable "security_groups" {
  type = any
}
