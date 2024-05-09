output "CONNECT_EC2_SSM" {
  value = flatten([
    for subnet_key in keys(module.ec2) : [
      for ec2_key in keys(module.ec2[subnet_key]["ec2"]) :
      format("aws ssm start-session --target %s --region ap-northeast-1", module.ec2[subnet_key]["ec2"][ec2_key]["id"])
    ]
  ])
}

output "CONNECT_EC2_SSM_REPLICA" {
  value = flatten([
    for subnet_key in keys(module.ec2_replica) : [
      for ec2_key in keys(module.ec2_replica[subnet_key]["ec2"]) :
      format("aws ssm start-session --target %s --region ap-northeast-3", module.ec2_replica[subnet_key]["ec2"][ec2_key]["id"])
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

output "CONNECT_EC2_SSH_REPLICA" {
  value = flatten([
    for subnet_key in keys(module.ec2_replica) : [
      for ec2_key in keys(module.ec2_replica[subnet_key]["ec2"]) :
      format("ssh -i ${local.private_key_file}-replica ec2-user@%s", module.ec2_replica[subnet_key]["ec2"][ec2_key]["public_dns"])
    ]
  ])
}
