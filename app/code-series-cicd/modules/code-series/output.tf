output "code_commit_git_clone" {
  value = "git clone codecommit::ap-northeast-1://${aws_codecommit_repository.this.id}"
}

output "web_site_ip" {
  value = {
    for instance_key, instance in module.ec2_server :
    instance_key => "curl http://${instance.public_ip}"
  }
}
