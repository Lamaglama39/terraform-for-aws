output "code_pipeline" {
  value = aws_codepipeline.this
}

output "event_bridge" {
  value = aws_cloudwatch_event_rule.this
}
