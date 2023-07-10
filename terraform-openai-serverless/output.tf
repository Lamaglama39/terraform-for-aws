output "aws_lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "aws_lambda_function_name" {
  value = aws_lambda_function.lambda.id
}

output "lambda_url" {
  value = "${aws_lambda_function_url.lambda_url.function_url}?api_model=gpt-3.5-turbo&system_text=YourOpenAI&user_text=Hello"
}

output "aws_cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}