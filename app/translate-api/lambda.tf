data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "app"
  output_path = "archive/my_lambda_function.zip"
}

resource "aws_lambda_function" "lambda" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "512"
  }

  function_name                  = var.lambda_function_name
  handler                        = "lambda.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = aws_iam_role.iam_role.arn
  runtime                        = "python3.8"
  filename                       = data.archive_file.function_source.output_path
  source_code_hash               = data.archive_file.function_source.output_base64sha256

  timeout = "3"

  environment {
    variables = {
      table_name = "${aws_dynamodb_table.dynamodb.name}"
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
}

# API GatewayからLambdaを呼び出すための許可設定
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

# Lambda用IAMロール
resource "aws_iam_role" "iam_role" {
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY

  description          = "iam_role_lambda-line-bot"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/TranslateFullAccess"]
  max_session_duration = "43200"
  name                 = "${var.lambda_function_name}-iam-role"
  path                 = "/"
}