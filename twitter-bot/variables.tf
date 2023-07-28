
# Resource Config
variable "lambda_name" {
  default = "twitter-bot-function"
}
variable "iamrole_name" {
  default = "twitter-bot-iam-role"
}
variable "dynamodb_name" {
  default = "twitter-bot-table"
}
variable "eventbridge_name" {
  default = "twitter-bot-event"
}

variable "eventbridge_schedule" {
  default = "rate(60 minutes)"
}

# twitter key,token
variable "api_key" {}
variable "api_secret_key" {}
variable "acces_token" {}
variable "acces_token_secrete" {}