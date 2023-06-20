# システム共通名
variable "project_name" {
  type    = string
  default = "openai"
}

# Lambda 設定
variable "lambda_function_name" {
  type    = string
  default = "openai-lambda"
}

# クレデンシャル情報
variable "API_Key" {}
variable "API_ENDPOINT" {}