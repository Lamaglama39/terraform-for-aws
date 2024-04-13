data "aws_caller_identity" "current" {}

module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  enabled             = local.enabled
  comment             = local.comment
  default_root_object = local.default_root_object
  http_version        = local.http_version
  is_ipv6_enabled     = local.is_ipv6_enabled
  price_class         = local.price_class

  ## オリジンアクセスコントロールの作成
  create_origin_access_control = local.create_origin_access_control
  origin_access_control = {
    s3_oac = {
      name             = local.origin_access_control.s3_oac.name
      description      = local.origin_access_control.s3_oac.description
      origin_type      = local.origin_access_control.s3_oac.origin_type
      signing_behavior = local.origin_access_control.s3_oac.signing_behavior
      signing_protocol = local.origin_access_control.s3_oac.signing_protocol
    }
  }

  ## オリジンの設定
  origin = [
    {
      origin_id                = local.bucket_name
      domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control_id = module.cloudfront.cloudfront_origin_access_controls_ids[0]
    }
  ]

  ## デフォルトのキャッシュ動作
  default_cache_behavior = {
    allowed_methods        = local.default_cache_behavior.allowed_methods
    cached_methods         = local.default_cache_behavior.cached_methods
    target_origin_id       = local.default_cache_behavior.target_origin_id
    viewer_protocol_policy = local.default_cache_behavior.viewer_protocol_policy
    min_ttl                = local.default_cache_behavior.min_ttl
    default_ttl            = local.default_cache_behavior.default_ttl
    max_ttl                = local.default_cache_behavior.max_ttl

    forwarded_values = {
      query_string = local.default_cache_behavior.forwarded_values.query_string
      cookies = {
        forward = local.default_cache_behavior.forwarded_values.cookies.forward
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate : true
  }
}

# S3バケットのモジュール
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.bucket_name
  force_destroy = local.force_destroy

  # # バケットポリシーを適用
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  # バケット所有権の制御
  object_ownership = local.object_ownership
}

# バケットポリシーのIAMポリシードキュメント
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.bucket_name}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }
  }
}


# Lambda layer
## モジュールインストール/zip処理
locals {
  source_dir_files = fileset("./app/python", "**/*")
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "python3 -m pip install -t ./app/python openai boto3"
  }
}

module "lambda_layer" {
  source = "terraform-aws-modules/lambda/aws"

  depends_on = [null_resource.install_dependencies]

  create_layer        = true
  layer_name          = "${local.app_name}-lambda-layer"
  description         = "OpenAI lambda layer"
  compatible_runtimes = ["python3.12"]

  source_path = "./app/python"
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name          = "${local.app_name}-lambda"
  description            = "${local.app_name}-lambda"
  handler                = local.handler_name
  architectures          = local.architectures
  ephemeral_storage_size = local.ephemeral_storage_size
  memory_size            = local.memory_size
  layers                 = local.layers

  runtime     = local.runtime
  source_path = local.source_path
  timeout     = local.timeout

  create_lambda_function_url = local.create_lambda_function_url
  authorization_type         = local.authorization_type

  cors = {
    allow_credentials = local.cors.allow_credentials
    allow_origins     = local.cors.allow_origins
    allow_methods     = local.cors.allow_methods
    allow_headers     = local.cors.allow_headers
    expose_headers    = local.cors.expose_headers
    max_age           = local.cors.max_age
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:*"],
      resources = ["arn:aws:dynamodb:${local.region}:${data.aws_caller_identity.current.account_id}:table/*"]
    }
  }

  environment_variables = local.environment_variables
  tracing_mode          = "PassThrough"

  tags = {
    Name = "${local.app_name}-lambda"
  }
}

module "aws_dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${local.app_name}-table"
  billing_mode   = local.billing_mode
  read_capacity  = local.read_capacity
  write_capacity = local.write_capacity
  hash_key       = local.hash_key

  attributes = [
    {
      name = local.attributes_name
      type = local.attributes_type
    }
  ]

  tags = {
    Name = "${local.app_name}-table"
  }
}
