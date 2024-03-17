# account1用
variable "account1" {
  type    = string
  default = "account1"
}

# account2用
variable "account2" {
  type    = string
  default = "account2"
}

# プロジェクト名
variable "project" {
  type    = string
  default = "transfer"
}

# ssh key 作成
variable "key_name" {
  type        = string
  description = "sftp-key"
  default     = "sftp-key"
}
