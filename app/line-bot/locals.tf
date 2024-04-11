locals {
  region      = "ap-northeast-1"
  default_tag = "terraform"
  app_name    = "line-bot"

  # event bridge
  create_bus          = false
  schedule_expression = "cron(0 21 * * ? *)"

  # lambda
  handler_name           = "lambda.handler"
  architectures          = ["x86_64"]
  ephemeral_storage_size = 512
  memory_size            = 128
  layers                 = ["arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:8"]
  runtime                = "python3.12"
  source_path            = "./app/lambda.py"
  timeout                = 10
  environment_variables = {
    api_url         = var.api_url
    token_event     = var.token_event
    token_garbage   = var.token_garbage
    user_id         = var.user_id
    table_name_day  = "${local.app_name}-dynamodb-day-table"
    table_name_week = "${local.app_name}-dynamodb-week-table"
  }

  # dynamodb table
  hash_key        = "hash"
  attributes_name = "hash"
  attributes_type = "S"
  billing_mode    = "PROVISIONED"
  read_capacity   = "1"
  write_capacity  = "1"

  json_data_day = file("./dynamodb_config/config_day.json")
  config_day    = jsondecode(local.json_data_day)
  json_data_week = file("./dynamodb_config/config_week.json")
  config_week    = jsondecode(local.json_data_week)
}
