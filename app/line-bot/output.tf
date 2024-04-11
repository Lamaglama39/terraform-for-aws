output "eventbridge" {
  value = module.eventbridge
}

output "lambda" {
  value = module.lambda
}

output "dynamodb_table_day" {
  value = module.aws_dynamodb_table_day
}

output "dynamodb_table_week" {
  value = module.aws_dynamodb_table_week
}
