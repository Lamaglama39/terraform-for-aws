resource "tls_private_key" "this" {
  algorithm = var.key_algorithm
}

resource "local_file" "private_key_pem" {
  filename        = var.private_key_file
  content         = tls_private_key.this.private_key_openssh
  file_permission = "0600"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name              = "${var.app_name}-key"
  public_key            = tls_private_key.this.public_key_openssh
  private_key_algorithm = var.key_algorithm
}
