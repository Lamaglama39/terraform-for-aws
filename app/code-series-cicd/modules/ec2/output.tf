output "web_site_ip" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "curl http://${instance.public_ip}"
  }
}
