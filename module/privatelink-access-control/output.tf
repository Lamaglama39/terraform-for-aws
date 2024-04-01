# EC2 接続コマンド
output "Connection_ec2_client_vpcpeering" {
  value = "aws ssm start-session --target ${aws_instance.ec2_client_vpcpeering.id} --region ap-northeast-1"
}
output "Connection_client_vpcendpoint" {
  value = "aws ssm start-session --target ${aws_instance.ec2_client_vpcendpoint.id} --region ap-northeast-1"
}

output "Connection_server_1" {
  value = "aws ssm start-session --target ${aws_instance.ec2_server_1.id} --region ap-northeast-1"
}
output "Connection_server_2" {
  value = "aws ssm start-session --target ${aws_instance.ec2_server_2.id} --region ap-northeast-1"
}

output "access_test_command" {
  value = "curl http://${aws_vpc_endpoint.privateLink.dns_entry[0].dns_name}"
}
