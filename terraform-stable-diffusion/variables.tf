# 共通Nameタグ
variable "name" {
  type    = string
  default = "terraform-stable-diffusion-webUI"
}

# EC2 設定
variable "ec2_instance_type" {
  default = "g5.xlarge"
}