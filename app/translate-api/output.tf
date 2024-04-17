output "aws_lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "aws_lambda_function_name" {
  value = aws_lambda_function.lambda.id
}

output "aws_api_gateway_deployment_invoke_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}${aws_api_gateway_resource.resource.path}?input_text=こんにちは"
}