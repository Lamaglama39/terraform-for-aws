# EC2 接続コマンド
output "ssm_command_Don't_Use_AssumeRole" {
  value = "aws ssm start-session --target ${aws_instance.ec2_1.id} --region ap-northeast-1"
}
output "ssm_command_Use_AssumeRole" {
  value = "aws ssm start-session --target ${aws_instance.ec2_2.id} --region ap-northeast-1"
}