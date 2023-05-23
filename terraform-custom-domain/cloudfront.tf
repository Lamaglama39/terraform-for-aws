resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  # オリジン設定
  origin {
    origin_id   = aws_s3_bucket.bucket.id
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  }

  # キャッシュ設定
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket.id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }
  }
  default_root_object = "index.html"
  enabled             = "true"
  http_version        = "http2"
  is_ipv6_enabled     = "true"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  // 代替ドメイン（CNAME）
  aliases = ["${local.custom_domain_name}"]
    viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

# OAC作成
resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = var.oac_name
  description                       = "Example OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}