output "code_commit" {
  value = aws_codecommit_repository.this
}

output "code_commit_git_clone" {
  value = "git clone codecommit::ap-northeast-1://${aws_codecommit_repository.this.id}"
}
