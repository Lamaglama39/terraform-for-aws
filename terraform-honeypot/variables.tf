# 共通Nameタグ
variable "name" {
  type    = string
  default = "terraform-honeypot"
}

# EC2 設定
variable "ec2_instance_type" {
  default = "t3.xlarge"
}

variable "timezone" {
  default = "Asia/Tokyo"
}

variable "linux_password" {
  default = "Tpot_admin_password"
  description = "default linux user password"
}

## tpot.conf 設定ファイル
variable "tpot_flavor" {
  type = string
  default     = "STANDARD"
  description = "tpot flavor [STANDARD, HIVE, HIVE_SENSOR, INDUSTRIAL, LOG4J, MEDICAL, MINI, SENSOR]"
}

variable "web_user" {
  type = string
  default     = "Tpot_web_user"
  description = "web user name"
}

variable "web_password" {
  type = string
  default = "Tpot_web_password"
  description = "web user password"
}