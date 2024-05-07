output "CURL_TO_NLB" {
  value = "curl ${module.elb.nlb.dns_name}"
}

output "CONNECT_EC2_SSM" {
  value = flatten([
    for subnet_key in keys(module.ec2) : [
      for ec2_key in keys(module.ec2[subnet_key]["ec2"]) :
      format("aws ssm start-session --target %s --region ap-northeast-1", module.ec2[subnet_key]["ec2"][ec2_key]["id"])
    ]
  ])
}

output "CONNECT_EC2_SSH" {
  value = flatten([
    for subnet_key in keys(module.ec2) : [
      for ec2_key in keys(module.ec2[subnet_key]["ec2"]) :
      format("ssh -i ${local.private_key_file} ec2-user@%s", module.ec2[subnet_key]["ec2"][ec2_key]["public_dns"])
    ]
  ])
}

output "CONNECT_RDS" {
  value = "mysql -h ${module.rds.rds.db_instance_address} -P ${local.port} -u ${local.username} -p"
}
