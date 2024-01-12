# EC2 接続コマンド
output "Connection_source_ec2" {
  value = "aws ssm start-session --target ${aws_instance.ec2_1.id} --region ap-northeast-1"
}
output "access_point_ec2" {
  value = "aws ssm start-session --target ${aws_instance.ec2_2.id} --region ap-northeast-1"
}
output "access_test_command" {
  value = "curl http://${aws_vpc_endpoint.privateLink.dns_entry[0].dns_name}"
}