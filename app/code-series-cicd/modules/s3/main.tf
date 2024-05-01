module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket_name
  force_destroy = var.force_destroy

  attach_policy = var.attach_policy
  policy = var.bucket_policy

  versioning = {
    enabled = "${var.versioning}"
  }
}
