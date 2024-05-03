# code build
resource "aws_codebuild_project" "this" {
  badge_enabled          = var.badge_enabled
  build_timeout          = var.build_timeout
  concurrent_build_limit = var.concurrent_build_limit
  encryption_key         = var.codebuild_project_encryption_key
  name                   = "${var.app_name}-codebuild-project"
  project_visibility     = var.codebuild_project_visibility
  queued_timeout         = var.queued_timeout
  resource_access_role   = var.resource_access_role
  service_role           = aws_iam_role.build.arn
  source_version         = var.source_version

  artifacts {
    artifact_identifier    = var.artifacts.artifact_identifier
    bucket_owner_access    = var.artifacts.bucket_owner_access
    encryption_disabled    = var.artifacts.encryption_disabled
    location               = var.build_bucket
    name                   = "${var.app_name}-codebuild-project"
    namespace_type         = var.artifacts.namespace_type
    override_artifact_name = var.artifacts.override_artifact_name
    packaging              = var.artifacts.packaging
    path                   = var.artifacts.path
    type                   = var.artifacts.type
  }

  cache {
    location = var.cache.location
    modes    = var.cache.modes
    type     = var.cache.type
  }

  environment {
    certificate                 = var.environment.certificate
    compute_type                = var.environment.compute_type
    image                       = var.environment.image
    image_pull_credentials_type = var.environment.image_pull_credentials_type
    privileged_mode             = var.environment.privileged_mode
    type                        = var.environment.type
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_logs.group_name
      status      = var.cloudwatch_logs.status
      stream_name = var.cloudwatch_logs.stream_name
    }

    s3_logs {
      bucket_owner_access = var.s3_logs.bucket_owner_access
      encryption_disabled = var.s3_logs.encryption_disabled
      location            = var.s3_logs.location
      status              = var.s3_logs.status
    }
  }

  source {
    buildspec           = var.codebuild_source.buildspec
    git_clone_depth     = var.codebuild_source.git_clone_depth
    insecure_ssl        = var.codebuild_source.insecure_ssl
    location            = "https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.app_name}-codecommit-repository"
    report_build_status = var.codebuild_source.report_build_status
    type                = var.codebuild_source.type
  }
}

resource "aws_iam_role" "build" {
  name                  = "${var.app_name}-codebuild-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
