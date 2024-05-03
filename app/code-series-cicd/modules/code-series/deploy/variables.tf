variable "app_name" {
  description = "This app name"
  type        = string
}

variable "region" {
  description = ""
  type        = string
  default = "ap-northeast-1"
}

# codedeploy
variable "compute_platform" {
  description = ""
  type        = string
  default = "Server"
}

variable "autoscaling_groups" {
  description = ""
  type        = list(string)
  default = []
}

variable "deployment_config_name" {
  description = ""
  type        = string
  default = "CodeDeployDefault.AllAtOnce"
}

variable "outdated_instances_strategy" {
  description = ""
  type        = string
  default = "UPDATE"
}

variable "deployment_style" {
  description = ""
  type        = object({
    deployment_option = string
    deployment_type   = string
  })
  default = {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
}

variable "ec2_tag_filter" {
  description = ""
  type        = object({
      key   = string
      type  = string
      value = string
  })
  default = {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "EC2"
  }
}
