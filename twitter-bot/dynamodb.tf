variable "items" {
  type    = string
  default = "./conf/item.json"
}

resource "aws_dynamodb_table" "dynamodb" {
  attribute {
    name = "hash"
    type = "S"
  }

  billing_mode = "PROVISIONED"
  hash_key     = "hash"
  name         = var.dynamodb_name

  point_in_time_recovery {
    enabled = "false"
  }

  read_capacity    = "1"
  stream_enabled   = "true"
  stream_view_type = "NEW_AND_OLD_IMAGES"

  write_capacity = "1"
}

# テーブルアイテムの設定
locals {
  json_data = file(var.items)
  config    = jsondecode(local.json_data)
}

resource "aws_dynamodb_table_item" "item" {
  for_each = local.config

  table_name = aws_dynamodb_table.dynamodb.name
  hash_key   = aws_dynamodb_table.dynamodb.hash_key

  item = jsonencode(each.value)
}