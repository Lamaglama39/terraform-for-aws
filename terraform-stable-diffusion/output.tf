# ssm session command
output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.server.id} --region ap-northeast-1"
}

# WebUI URL
output "web_ui" {
  value = "https://${aws_eip.eip.public_ip}:7860"
}