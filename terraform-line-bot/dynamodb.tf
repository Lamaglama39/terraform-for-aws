# 日付用dynamodbテーブル
resource "aws_dynamodb_table" "dynamodb_day" {
  attribute {
    name = "hash"
    type = "S"
  }

  billing_mode = "PROVISIONED"
  hash_key     = "hash"
  name         = var.table_name_day

  point_in_time_recovery {
    enabled = "false"
  }

  read_capacity    = "1"
  stream_enabled   = "true"
  stream_view_type = "NEW_AND_OLD_IMAGES"

  write_capacity = "1"
}

locals {
  json_data_day = file("./dynamodb_config/config_day.json")         
  config_day    = jsondecode(local.json_data_day)
}

resource "aws_dynamodb_table_item" "item_day" {
  for_each = local.config_day

  table_name = aws_dynamodb_table.dynamodb_day.name
  hash_key   = aws_dynamodb_table.dynamodb_day.hash_key

  item = jsonencode(each.value)             
}

# 曜日用dynamodbテーブル
resource "aws_dynamodb_table" "dynamodb_week" {
  attribute {
    name = "hash"
    type = "S"
  }

  billing_mode = "PROVISIONED"
  hash_key     = "hash"
  name         = var.table_name_week

  point_in_time_recovery {
    enabled = "false"
  }

  read_capacity    = "1"
  stream_enabled   = "true"
  stream_view_type = "NEW_AND_OLD_IMAGES"

  write_capacity = "1"
}

locals {
  json_data_week = file("./dynamodb_config/config_week.json")         
  config_week    = jsondecode(local.json_data_week)
}

resource "aws_dynamodb_table_item" "item_week" {
  for_each = local.config_week

  table_name = aws_dynamodb_table.dynamodb_week.name
  hash_key   = aws_dynamodb_table.dynamodb_week.hash_key

  item = jsonencode(each.value)             
}