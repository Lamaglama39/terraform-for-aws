output "aws_lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "aws_lambda_function_name" {
  value = aws_lambda_function.lambda.id
}

output "lambda_url" {
  value = "curl ${aws_lambda_function_url.lambda_url.function_url}?input_text=Hello."
}