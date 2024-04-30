variable "app_name" {
  description = "This app name"
  type        = string
}

variable "region" {
  description = ""
  type        = string
  default = "ap-northeast-1"
}

# code commit
variable "default_branch" {
  description = "The default branch of the repository."
  type        = string
}

variable "kms_key_id" {
  description = "The ARN of the encryption key."
  type        = string
  default     = null
}

# code build
variable "badge_enabled" {
  description = "Generates a publicly-accessible URL for the projects build badge."
  type        = string
  default = false
}

variable "build_timeout" {
  description = "Number of minutes, from 5 to 2160 (36 hours)"
  type        = number
  default = 60
}

variable "concurrent_build_limit" {
  description = "Specify a maximum number of concurrent builds for the project."
  type        = number
  default = null
}

variable "codebuild_project_description" {
  description = "Short description of the project."
  type        = string
  default = null
}

variable "codebuild_project_encryption_key" {
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to be used for encrypting the build project's build output artifacts."
  type        = string
  default = null
}

variable "codebuild_project_visibility" {
  description = "Specifies the visibility of the project's builds"
  type        = string
  default = "PRIVATE"
}

variable "queued_timeout" {
  description = "Number of minutes, from 5 to 480 (8 hours)"
  type        = number
  default = 480
}

variable "resource_access_role" {
  description = "The ARN of the IAM role that enables CodeBuild to access the CloudWatch Logs and Amazon S3 artifacts for the project's builds in order to display them publicly"
  type        = string
  default = null
}

variable "source_version" {
  description = "Version of the build input to be built for this project."
  type        = string
  default = "main"
}

variable "artifacts" {
  description = ""
  type        = object({
    artifact_identifier    = string
    bucket_owner_access    = string
    encryption_disabled    = bool
    location               = string
    name                   = string
    namespace_type         = string
    override_artifact_name = bool
    packaging              = string
    path                   = string
    type                   = string
  })
  default = {
    artifact_identifier    = null
    bucket_owner_access    = null
    encryption_disabled    = false
    location               = null
    name                   = null
    namespace_type         = "NONE"
    override_artifact_name = false
    packaging              = "NONE"
    path                   = null
    type                   = "S3"
  }
}

variable "cache" {
  description = ""
  type        = object({
    location = string
    modes    = list(string)
    type     = string
  })
  default = {
    location = null
    modes    = []
    type     = "NO_CACHE"
  }
}

variable "environment" {
  description = ""
  type        = object({
    certificate                 = string
    compute_type                = string
    image                       = string
    image_pull_credentials_type = string
    privileged_mode             = bool
    type                        = string
  })
  default = {
    certificate                 = null
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:corretto8-24.08.23"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }
}

variable "cloudwatch_logs" {
  description = ""
  type        = object({
      group_name  = string
      status      = string
      stream_name = string
  })
  default = {
      group_name  = null
      status      = "ENABLED"
      stream_name = null
  }
}

variable "s3_logs" {
  description = ""
  type        = object({
      bucket_owner_access = string
      encryption_disabled = bool
      location            = string
      status              = string
  })
  default = {
      bucket_owner_access = null
      encryption_disabled = false
      location            = null
      status              = "DISABLED"
  }
}

variable "codebuild_source" {
  description = ""
  type        = object({
    buildspec           = string
    git_clone_depth     = number
    insecure_ssl        = bool
    location            = string
    report_build_status = bool
    type                = string
  })
  default = {
    buildspec           = null
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = null
    report_build_status = false
    type                = "CODECOMMIT"
  }
}

variable "build_bucket" {
  description = ""
  type        = string
}

# codedeploy
variable "compute_platform" {
  description = ""
  type        = string
  default = "Server"
}

variable "autoscaling_groups" {
  description = ""
  type        = list(string)
  default = []
}

variable "deployment_config_name" {
  description = ""
  type        = string
  default = "CodeDeployDefault.AllAtOnce"
}

variable "outdated_instances_strategy" {
  description = ""
  type        = string
  default = "UPDATE"
}

variable "deployment_style" {
  description = ""
  type        = object({
    deployment_option = string
    deployment_type   = string
  })
  default = {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
}

variable "ec2_tag_filter" {
  description = ""
  type        = object({
      key   = string
      type  = string
      value = string
  })
  default = {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "EC2"
  }
}


# codepipeline
variable "pipeline_bucket" {
  description = ""
  type        = string
}

variable "execution_mode" {
  description = ""
  type        = string
  default = "QUEUED"
}

variable "pipeline_type" {
  description = ""
  type        = string
  default = "V2"
}
