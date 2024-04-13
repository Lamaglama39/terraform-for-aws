output "cloudfront" {
  value = module.cloudfront
}

output "s3_bucket" {
  value = module.s3_bucket
}

output "lambda_layer" {
  value = module.lambda_layer
}

output "lambda" {
  value = module.lambda
}

output "dynamodb" {
  value = module.aws_dynamodb_table
}

output "lambda_url" {
  value = "${module.lambda.lambda_function_url}?api_model=gpt-3.5-turbo&system_text=YourOpenAI&user_text=Hello"
}

output "aws_cloudfront_distribution_domain_name" {
  value = "https://${module.cloudfront.cloudfront_distribution_domain_name}"
}
