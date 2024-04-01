# API実行履歴保管用 Dynamodb
resource "aws_dynamodb_table" "dynamodb" {
  name         = "${var.project_name}-table"
  billing_mode = "PROVISIONED"
  hash_key     = "timestamp"
  attribute {
    name = "timestamp"
    type = "S"
  }

  point_in_time_recovery {
    enabled = "false"
  }

  read_capacity    = "1"
  write_capacity   = "1"
  stream_enabled   = "true"
  stream_view_type = "NEW_AND_OLD_IMAGES"

}