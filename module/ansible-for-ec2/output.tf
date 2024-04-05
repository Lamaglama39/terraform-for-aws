# SSHコマンドの出力
output "ssh_command" {
  value = {
    for key, instance in aws_instance.server :
    key => "ssh -i ${local.private_key_file} ec2-user@${instance.public_ip}"
  }
}

output "ssm_command" {
  value = {
    for key, instance in aws_instance.server :
    key => "aws ssm start-session --target ${instance.id} --region ap-northeast-1"
  }
}
