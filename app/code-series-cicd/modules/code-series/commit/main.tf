# code commit
resource "aws_codecommit_repository" "this" {
  repository_name = "${var.app_name}-codecommit-repository"
  description     = "${var.app_name}-codecommit-repository"
  default_branch  = var.default_branch
  kms_key_id      = var.kms_key_id
}
