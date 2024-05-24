output "s3" {
  value = aws_s3_bucket.main
}

output "s3_bucket_ownership_controls" {
  value = aws_s3_bucket_ownership_controls.main
}

output "s3_bucket_versioning" {
  value = aws_s3_bucket_versioning.main
}

output "s3_bucket_server_side_encryption_configuration" {
  value = aws_s3_bucket_server_side_encryption_configuration.main
}
