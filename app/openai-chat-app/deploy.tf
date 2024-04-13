# react S3アップロード処理
resource "null_resource" "build_and_deploy" {
  triggers = {
    build_trigger = "${timestamp()}"
  }

  depends_on = [module.cloudfront]

  provisioner "local-exec" {
    command = <<EOF
      cd ./react
      echo "VITE_LAMBDA_URL=${module.lambda.lambda_function_url}" > .env
      sellp 10
      yarn
      yarn build
      aws s3 cp --recursive dist s3://${module.s3_bucket.s3_bucket_id}
    EOF
  }
}
