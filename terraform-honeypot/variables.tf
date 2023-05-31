# 共通Nameタグ
variable "name" {
  type    = string
  default = "terraform-honeypot"
}

# Tpot 設定
variable "Tpot_user" {
  type = string
  default = "Tpot_admin_user"
}
variable "Tpot_password" {
  type = string
  default = "Tpot_admin_password"
}