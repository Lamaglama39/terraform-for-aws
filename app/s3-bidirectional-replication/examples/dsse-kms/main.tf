module "kms_primary" {
  source = "../../modules/kms"

  app_name = "${local.app_name}-tokyo"
}

module "kms_secondary" {
  source = "../../modules/kms"
  providers = { aws = aws.secondary }

  app_name = "${local.app_name}-osaka"
}

module "s3_primary" {
  source = "../../modules/s3"

  app_name = "${local.app_name}-tokyo"
  encryption_type = local.encryption_type
  kms_key_arn     = module.kms_primary.aws_kms_key.key_id
  depends_on = [ module.kms_primary,module.kms_secondary ]
}

module "s3_secondary" {
  source    = "../../modules/s3"
  providers = { aws = aws.secondary }

  app_name = "${local.app_name}-osaka"
  encryption_type = local.encryption_type
  kms_key_arn     = module.kms_secondary.aws_kms_key.key_id
  depends_on = [ module.kms_primary,module.kms_secondary ]
}

module "s3_replication_primary" {
  source = "../../modules/s3_replication"

  app_name              = "${local.app_name}-tokyo"
  source_s3_bucket      = module.s3_primary.s3.bucket
  source_kms_key_id     = module.kms_primary.aws_kms_key.arn
  replication_s3_bucket = module.s3_secondary.s3.bucket
  replica_kms_key_id    = module.kms_secondary.aws_kms_key.arn
  depends_on = [ module.s3_primary,module.s3_secondary ]
}

module "s3_replication_secondary" {
  source    = "../../modules/s3_replication"
  providers = { aws = aws.secondary }

  app_name              = "${local.app_name}-osaka"
  source_s3_bucket      = module.s3_secondary.s3.bucket
  source_kms_key_id     = module.kms_secondary.aws_kms_key.arn
  replication_s3_bucket = module.s3_primary.s3.bucket
  replica_kms_key_id    = module.kms_primary.aws_kms_key.arn
  depends_on = [ module.s3_primary,module.s3_secondary ]
}
