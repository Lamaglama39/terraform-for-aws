output "aws_lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "aws_dynamodb_table_arn" {
  value = aws_dynamodb_table.dynamodb.arn
}

output "aws_cloudwatch_event_arn" {
  value = aws_cloudwatch_event_rule.event.arn
}