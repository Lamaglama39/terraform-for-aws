# react S3アップロード処理
resource "null_resource" "build_and_deploy" {
  triggers = {
    build_trigger = "${timestamp()}"
  }

  depends_on = [ aws_cloudfront_distribution.cloudfront_distribution ]

  provisioner "local-exec" {
    command = <<EOF
      cd ./react
      echo "VITE_LAMBDA_URL=${aws_lambda_function_url.lambda_url.function_url}" > .env
      sellp 10
      yarn
      yarn build
      aws s3 cp --recursive dist s3://${aws_s3_bucket.bucket.id}
    EOF
  }
}