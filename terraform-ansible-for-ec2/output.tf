# 管理用サーバ 接続コマンド
output "ssh_command" {
  value = "ssh -i ${local.private_key_file} ec2-user@${aws_instance.server.public_ip}"
}

output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.server.id} --region ap-northeast-1"
}