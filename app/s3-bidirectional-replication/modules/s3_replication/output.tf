output "iam_policy" {
  value = aws_iam_policy.main
}

output "iam_role" {
  value = aws_iam_role.main
}

output "s3_bucket_replication_configuration" {
  value = aws_s3_bucket_replication_configuration.main
}
