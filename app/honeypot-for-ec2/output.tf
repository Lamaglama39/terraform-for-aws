output "vpc" {
  value = module.vpc
}

output "sg" {
  value = module.vote_service_sg
}

output "iam" {
  value = module.iam_assumable_role
}

output "key" {
  value = tls_private_key.this.public_key_openssh
}

output "ec2_server" {
  value = module.ec2_server
}

output "ssm_command" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "aws ssm start-session --target ${instance.id} --region ${local.region}"
  }
}

output "ssh_commands" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "ssh -i ${local.private_key_file} ec2-user@${instance.public_ip}"
  }
}

output "ssh_ui" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "https://${instance.public_ip}:64294"
  }
}
output "web_ui" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "https://${instance.public_ip}:64297"
  }
}
