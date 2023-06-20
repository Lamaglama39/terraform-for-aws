data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "app/function"
  output_path = "archive/lambda_function.zip"
}

locals {
  source_dir_files = fileset("app/python", "**/*")
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "python3 -m pip install -t ./app/python openai"
  }
}

resource "null_resource" "layer_source" {
  depends_on = [null_resource.install_dependencies]

  triggers = {
    source_dir_hash = join(",", [for f in local.source_dir_files : filemd5("app/python/${f}")])
  }

  provisioner "local-exec" {
    command = "cd app && zip -r ../archive/openai.zip python"
  }
}

resource "aws_lambda_function" "lambda" {
  architectures = ["x86_64"]

  ephemeral_storage {
    size = "512"
  }

  function_name                  = var.lambda_function_name
  handler                        = "lambda_function.lambda_handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = aws_iam_role.iam_role.arn
  runtime                        = "python3.9"
  filename                       = data.archive_file.function_source.output_path
  source_code_hash               = data.archive_file.function_source.output_base64sha256
  layers = ["${aws_lambda_layer_version.lambda_layer.arn}"]

  timeout = "30"

  environment {
    variables = {
      API_Key = var.API_Key,
      API_ENDPOINT = var.API_ENDPOINT
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
}

# Lambda レイヤー
resource "aws_lambda_layer_version" "lambda_layer" {
  depends_on = [null_resource.layer_source]

  layer_name = "openai"
  filename   = "archive/openai.zip"

  compatible_runtimes = ["python3.9"]
  compatible_architectures = ["x86_64"]
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