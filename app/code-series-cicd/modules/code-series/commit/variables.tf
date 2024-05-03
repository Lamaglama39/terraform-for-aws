variable "app_name" {
  description = "This app name"
  type        = string
}

variable "region" {
  description = ""
  type        = string
  default = "ap-northeast-1"
}

# code commit
variable "default_branch" {
  description = "The default branch of the repository."
  type        = string
}

variable "kms_key_id" {
  description = "The ARN of the encryption key."
  type        = string
  default     = null
}
