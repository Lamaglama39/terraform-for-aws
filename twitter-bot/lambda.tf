# Lambda関数のソースコードをzip形式で作成
data "archive_file" "function_source" {

  type        = "zip"
  source_dir  = "app"
  output_path = "archive/my_lambda_function.zip"
}

# Lambda関数の作成
resource "aws_lambda_function" "lambda" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "512"
  }
  function_name                  = "twitter_bot"
  handler                        = "lambda.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = aws_iam_role.iam_role.arn
  runtime                        = "python3.9"
  filename         = data.archive_file.function_source.output_path
  source_code_hash = data.archive_file.function_source.output_base64sha256

  timeout = "5"

  # Twitterクレデンシャル情報の設定
  environment {
    variables = {
      api_key = "${var.api_key}"
      api_secret_key = "${var.api_secret_key}"
      acces_token = "${var.acces_token}"
      acces_token_secrete  = "${var.acces_token_secrete}"
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
}

# Lambda関数の実行権限を設定
resource "aws_lambda_permission" "allow_evemts" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event.arn
}

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

  description          = "iam_role_lambda-twitter-bot"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"]
  max_session_duration = "43200"
  name                 = "iam_role_lambda-twitter-bot"
  path                 = "/"
}