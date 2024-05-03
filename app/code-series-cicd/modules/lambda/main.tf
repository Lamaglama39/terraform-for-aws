module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.app_name}-lambda"
  description   = "${var.app_name}-lambda"
  handler       = var.handler
  runtime       = var.runtime
  create_lambda_function_url = true

  source_path = var.source_path
}
