output "aws_s3_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "aws_cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}