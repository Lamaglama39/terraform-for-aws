# API実行履歴保管用 Dynamodb
resource "aws_dynamodb_table" "dynamodb" {
  name         = "${var.project_name}-table"
  billing_mode = "PROVISIONED"
  hash_key     = "sourceIp"
  attribute {
    name = "sourceIp"
    type = "S"
  }

  point_in_time_recovery {
    enabled = "false"
  }

  ttl {
    attribute_name = "Timeout"
    enabled        = true
  }

  read_capacity    = "1"
  write_capacity   = "1"
  stream_enabled   = "true"
  stream_view_type = "NEW_AND_OLD_IMAGES"
}