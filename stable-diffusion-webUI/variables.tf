# 共通Nameタグ
variable "name" {
  type    = string
  default = "terraform-stable-diffusion-webUI"
}

# EC2 設定
variable "ec2_instance_type" {
  # default = "g5.xlarge"
  default = "t3.micro"
}

# スポットインスタンスリクエスト 終了時間
variable "end_time" {
  default = "1h"
}

# スポットインスタンスリクエスト 最高価格
variable "price" {
  default = "0.6"
}