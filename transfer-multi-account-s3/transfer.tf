# SFTPサーバ
resource "aws_transfer_server" "server" {
  identity_provider_type = "SERVICE_MANAGED"
  endpoint_type          = "VPC"
  protocols              = ["SFTP"]
  domain                 = "S3"

  endpoint_details {
    vpc_id             = aws_vpc.vpc.id
    subnet_ids         = [aws_subnet.public.id]
    security_group_ids = [aws_security_group.server.id]
  }

  structured_log_destinations = [
    "${aws_cloudwatch_log_group.transfer.arn}:*"
  ]

  tags = {
    Name = "${var.project}-sftp-server"
  }
}

# CloudWatchLogグループ
resource "aws_cloudwatch_log_group" "transfer" {
  name_prefix = "${var.project}_log"
}

# SFTPユーザー用IAM
data "aws_iam_policy_document" "assume_role_sftp" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_sftp" {
  name               = "${var.project}-sftp-user-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_sftp.json
}

data "aws_iam_policy_document" "s3_document" {
  statement {
    sid     = "AllowFullAccesstoS3"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.bucket_1.arn}",
      "${aws_s3_bucket.bucket_1.arn}/*",
      "${aws_s3_bucket.bucket_2.arn}",
      "${aws_s3_bucket.bucket_2.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_policy" {
  name   = "${var.project}-sftp-user-s3-policy"
  role   = aws_iam_role.role_sftp.id
  policy = data.aws_iam_policy_document.s3_document.json
}

# SFTPユーザー
resource "aws_transfer_user" "user" {
  server_id = aws_transfer_server.server.id
  user_name = "${var.project}-sftp-user"
  role      = aws_iam_role.role_sftp.arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/s3-1"
    target = "/${aws_s3_bucket.bucket_1.bucket}/data"
  }

  home_directory_mappings {
    entry  = "/s3-2"
    target = "/${aws_s3_bucket.bucket_2.bucket}/data"
  }
  # home_directory_type = "PATH"
  # home_directory      = "/${aws_s3_bucket.bucket_1.bucket}"
}

# SSH鍵
locals {
  public_key_file  = "./.key_pair/${var.key_name}.pem.pub"
  private_key_file = "./.key_pair/${var.key_name}.pem"
}

resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_openssh" {
  filename = local.public_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

# SFTPユーザー用SSH鍵
resource "aws_transfer_ssh_key" "ssh_key" {
  server_id = aws_transfer_server.server.id
  user_name = aws_transfer_user.user.user_name
  body      = tls_private_key.keygen.public_key_openssh
}

# クライアントEC用 key pair 作成
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.keygen.public_key_openssh
}

# ssh key 送信
resource "local_file" "put_private_key_server" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} ${local.private_key_file} ec2-user@${aws_instance.client.public_ip}:/home/ec2-user/.ssh"
  }
  depends_on = [aws_instance.client]
}

resource "local_file" "put_public_key_server" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "scp -i ${local.private_key_file} ${local.public_key_file} ec2-user@${aws_instance.client.public_ip}:/home/ec2-user/.ssh"
  }
  depends_on = [aws_instance.client]
}
