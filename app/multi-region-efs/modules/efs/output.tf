output "efs" {
  value = aws_efs_file_system.main
}

output "file_system_policy" {
  value = aws_efs_file_system_policy.main
}

output "mount_target" {
  value = aws_efs_mount_target.main
}
