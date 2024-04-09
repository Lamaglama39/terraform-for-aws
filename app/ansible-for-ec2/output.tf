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

output "ec2_client" {
  value = module.ec2_client
}

output "ssh_commands" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "ssh -i ${local.private_key_file} ec2-user@${instance.public_ip}"
  }
}
