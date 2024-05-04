output "code_commit_git_clone" {
  value = module.code_commit.code_commit_git_clone
}

output "public_ips" {
  description = "All public IPs of EC2 instances"
  value       = flatten([
    for subnet_key in keys(module.ec2) : [
      for ec2_key in keys(module.ec2[subnet_key]["ec2"]) :
        format("curl http://%s", module.ec2[subnet_key]["ec2"][ec2_key]["public_ip"]) 
    ]
  ])
}
