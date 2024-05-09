variable "app_name" {
  type = string
}

variable "primary_region" {
  type = string
}

variable "secondary_region" {
  type = string
}

variable "encrypted" {
  type = bool
  default = true
}

variable "kms_key_arn" {
  type = string
  default = null
}

variable "lifecycle_policy" {
  type = any
  default = {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

variable "mount_targets" {
  type = any
  default = {
    "eu-west-1a" = {
      subnet_id = "subnet-abcde012"
    }
    "eu-west-1b" = {
      subnet_id = "subnet-bcde012a"
    }
    "eu-west-1c" = {
      subnet_id = "subnet-fghi345a"
    }
  }
}

variable "security_group_vpc_id" {
  type = string
}

variable "sg_cidr_blocks" {
  type = list(string)
}
