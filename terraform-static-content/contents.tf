# S3へのアップロード設定
resource "aws_s3_object" "html-object" {
  bucket = aws_s3_bucket.bucket.id
  key = "index.html"
  source = "contents/index.html"
  content_type = "text/html"
  etag = filemd5("contents/index.html")
}

resource "aws_s3_object" "css-object" {
  bucket = aws_s3_bucket.bucket.id
  key = "stylesheet.css"
  source = "contents/stylesheet.css"
  content_type = "text/css"
  etag = filemd5("contents/stylesheet.css")
}