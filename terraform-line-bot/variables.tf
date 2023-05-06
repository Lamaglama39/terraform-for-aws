# line クレデンシャル情報
variable "api_url" {}
variable "token_event" {}
variable "token_garbage" {}
variable "user_id" {}

# dynamodb テーブル名
variable "table_name_day" {
  type    = string
  default = "line_table_day"
}
variable "table_name_week" {
  type = string
  default = "line_table_week"
}