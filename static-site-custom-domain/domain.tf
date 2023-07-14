# ドメイン定義
locals {
  cert_domain_name = "*.example.com"
  custom_domain_name = "subdomain.example.com"
  zone_name        = "example.com"
}

# ACM証明書
resource "aws_acm_certificate" "cert" {
  domain_name       = local.cert_domain_name
  validation_method = "DNS"
  provider          = "aws.virginia"

  lifecycle {
    create_before_destroy = true
  }
}

# Route53
data "aws_route53_zone" "zone" {
  name         = local.zone_name
  private_zone = false
}

# Route53 CNAMEレコード
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.zone.id
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# Route53 Aレコード
resource "aws_route53_record" "info" {
  zone_id = data.aws_route53_zone.zone.id
  name    = local.custom_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# 検証
resource "aws_acm_certificate_validation" "example" {
  provider          = "aws.virginia"
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}