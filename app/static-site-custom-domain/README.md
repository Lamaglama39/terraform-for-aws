# terraform-custom-domain
Route53とCloudFrontを利用した、カスタムドメインの静的Webサイトを作成します。
<br>
ただしRoute53でのドメイン取得はterraform管理範囲外のため、事前に準備してください。
<br>
またRoute53のホストゾーンはドメイン取得時のデフォルトのものを使用します。

# 構成図
<p>
<img width="75%" src="./src/terraform-custom-domain.png">
</p>

# 使い方

(1)「./contents/」配下にコンテンツ用のリソースを配置します。
```
example.html
example.css
```

(2)「contents.tf」に配置したリソースのパスを追加します。
```
resource "aws_s3_object" "html-object" {
  bucket = aws_s3_bucket.bucket.id
  key = "example.html"
  source = "contents/example.html"
  content_type = "text/html"
  etag = filemd5("contents/example.html")
}
resource "aws_s3_object" "css-object" {
  bucket = aws_s3_bucket.bucket.id
  key = "example.css"
  source = "contents/example.css"
  content_type = "text/css"
  etag = filemd5("contents/example.css")
}
```

(3)「domain.tf」にドメイン名を記載します。
```
locals {
  cert_domain_name = "*.example.com"
  custom_domain_name = "subdomain.example.com"
  zone_name        = "example.com"
}
```

(4)terraformコマンドでapplyします。
```
$ terraform init
$ terraform apply
```

(5)「Outputs:」に出力されるドメイン名にアクセスしましょう。
```
aws_cloudfront_distribution_custom_domain_name = toset([
  "subdomain.example.com",
])
aws_cloudfront_distribution_domain_name = "XXXXXXXXXXXXX.cloudfront.net"
```

# ライセンス
[Mozilla Public License v2.0](https://github.com/Lamaglama39/terraform-for-aws/blob/main/LICENSE)

# 素材クレジット
- <a target="_blank" href="https://icons8.com/icon/WncR8Bcg5nE9/terraform">Terraform</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>