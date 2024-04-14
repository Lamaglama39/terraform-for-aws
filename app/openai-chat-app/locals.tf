locals {
  region      = "ap-northeast-1"
  default_tag = "terraform"
  app_name    = "openai-bot"

  # cloudfront
  enabled             = true
  comment             = "${local.app_name} CloudFront Distribution"
  default_root_object = "index.html"
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  ## オリジンアクセスコントロールの作成
  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      name             = "${local.app_name}-oac"
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  ## デフォルトのキャッシュ動作
  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${local.app_name}-s3-website"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }

  # s3
  bucket_name      = "${local.app_name}-s3-website"
  force_destroy    = true
  object_ownership = "BucketOwnerEnforced"


  # lambda
  handler_name               = "lambda_function.lambda_handler"
  architectures              = ["x86_64"]
  ephemeral_storage_size     = 512
  memory_size                = 128
  layers                     = [module.lambda_layer.lambda_layer_arn]
  runtime                    = "python3.12"
  source_path                = "./app/function/lambda_function.py"
  timeout                    = 60

  create_lambda_function_url = true
  authorization_type         = "NONE"
  cors = {
    allow_credentials = true
    allow_origins     = ["https://${module.cloudfront.cloudfront_distribution_domain_name}"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }

  environment_variables = {
    API_Key      = var.OPENAI_API_Key,
    API_ENDPOINT = var.OPENAI_API_ENDPOINT
    TABLE_NAME = "${local.app_name}-table"
  }

  # dynamodb table
  hash_key        = "sourceIp"
  attributes_name = "sourceIp"
  attributes_type = "S"
  billing_mode    = "PROVISIONED"
  read_capacity   = "1"
  write_capacity  = "1"

}
