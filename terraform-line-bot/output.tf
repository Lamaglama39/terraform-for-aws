output "aws_lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "aws_lambda_function_name" {
  value = aws_lambda_function.lambda.id
}

output "aws_dynamodb_table_day_arn" {
  value = aws_dynamodb_table.dynamodb_day
}

output "aws_dynamodb_table_week_arn" {
  value = aws_dynamodb_table.dynamodb_week
}

output "aws_cloudwatch_event_arn" {
  value = aws_cloudwatch_event_rule.event.arn
}