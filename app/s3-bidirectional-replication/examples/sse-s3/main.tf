module "s3_primary" {
  source = "../../modules/s3"

  app_name = "${local.app_name}-tokyo"
}

module "s3_secondary" {
  source    = "../../modules/s3"
  providers = { aws = aws.secondary }

  app_name = "${local.app_name}-osaka"
}

module "s3_replication_primary" {
  source = "../../modules/s3_replication"

  app_name              = "${local.app_name}-tokyo"
  source_s3_bucket      = module.s3_primary.s3.bucket
  replication_s3_bucket = module.s3_secondary.s3.bucket
  depends_on = [ module.s3_primary,module.s3_secondary ]
}

module "s3_replication_secondary" {
  source    = "../../modules/s3_replication"
  providers = { aws = aws.secondary }

  app_name              = "${local.app_name}-osaka"
  source_s3_bucket      = module.s3_secondary.s3.bucket
  replication_s3_bucket = module.s3_primary.s3.bucket
  depends_on = [ module.s3_primary,module.s3_secondary ]
}
