# honeypot server 接続コマンド

output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.server.id} --region ap-northeast-1"
}

output "ssh_command" {
  value = "https://${aws_eip.eip.public_ip}:64294"
}
output "web_ui" {
  value = "https://${aws_eip.eip.public_ip}:64297"
}