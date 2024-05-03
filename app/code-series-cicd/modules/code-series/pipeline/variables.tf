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

# codepipeline
variable "pipeline_bucket" {
  description = ""
  type        = string
}

variable "execution_mode" {
  description = ""
  type        = string
  default = "QUEUED"
}

variable "pipeline_type" {
  description = ""
  type        = string
  default = "V2"
}
