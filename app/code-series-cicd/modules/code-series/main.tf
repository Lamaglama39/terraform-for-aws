data "aws_caller_identity" "self" { }

# code commit
resource "aws_codecommit_repository" "this" {
  repository_name = "${var.app_name}-codecommit-repository"
  description     = "${var.app_name}-codecommit-repository"
  default_branch  = var.default_branch
  kms_key_id      = var.kms_key_id
}

# codebuild project
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
    location               = var.build_artifact_bucket
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


data "aws_iam_policy_document" "build" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${var.app_name}-codebuild-project",
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${var.app_name}-codebuild-project:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::${var.pipeline_bucket}",
      "arn:aws:s3:::${var.pipeline_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:GitPull",
    ]
    resources = [
      "arn:aws:codecommit:${var.region}:${data.aws_caller_identity.self.account_id}:${var.app_name}-codecommit-repository",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::${var.build_artifact_bucket}",
      "arn:aws:s3:::${var.build_artifact_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.self.account_id}:report-group/${var.app_name}-codebuild-project-*",
    ]
  }
}

resource "aws_iam_policy" "build" {
  name        = "${var.app_name}-codebuild-iam-policy"
  description = "${var.app_name}-codebuild-iam-policy"
  policy      = data.aws_iam_policy_document.build.json
}

resource "aws_iam_role_policy_attachment" "build" {
  policy_arn = aws_iam_policy.build.arn
  role       = aws_iam_role.build.name
}

resource "aws_iam_role_policy_attachment" "DeployerAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
  role       = aws_iam_role.build.name
}

resource "aws_s3_bucket" "build" {
  bucket              = var.build_artifact_bucket
  force_destroy = true
}

resource "aws_codedeploy_app" "this" {
  name        = "${var.app_name}-codedeploy-app"
  compute_platform = var.compute_platform
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name                    = "${var.app_name}-codedeploy-app"
  deployment_group_name       = "${var.app_name}-codedeploy-deployment-group"

  autoscaling_groups          = var.autoscaling_groups
  deployment_config_name      = var.deployment_config_name
  outdated_instances_strategy = var.outdated_instances_strategy
  service_role_arn            = aws_iam_role.deployment.arn

  deployment_style {
    deployment_option = var.deployment_style.deployment_option
    deployment_type   = var.deployment_style.deployment_type
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = var.ec2_tag_filter.key
      type  = var.ec2_tag_filter.type
      value = var.ec2_tag_filter.value
    }
  }
}

resource "aws_iam_role_policy_attachment" "deployment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.deployment.name
}

resource "aws_iam_role" "deployment" {
  name                  = "${var.app_name}-codedeploy-iam-role" 

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_codepipeline" "this" {
  name           = "${var.app_name}-codepipeline" 
  role_arn       = aws_iam_role.pipeline.arn
  pipeline_type  = var.pipeline_type
  execution_mode = var.execution_mode

  artifact_store {
    location = aws_s3_bucket.pipeline.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category = "Source"
      name               = "Source"
      namespace          = "SourceVariables"
      owner              = "AWS"
      provider           = "CodeCommit"
      version            = 1
      output_artifacts   = ["SourceArtifact"]

      configuration = {
        RepositoryName       = "${var.app_name}-codecommit-repository"
        BranchName           = var.default_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      name               = "Build"
      namespace          = "BuildVariables"
      owner              = "AWS"
      provider           = "CodeBuild"
      version            = 1
      input_artifacts    = ["SourceArtifact"]
      output_artifacts   = ["BuildArtifact"]

      configuration = {
        ProjectName = "${var.app_name}-codebuild-project"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category = "Deploy"
      name               = "Deploy"
      namespace          = "DeployVariables"
      owner              = "AWS"
      provider           = "CodeDeploy"
      version            = 1
      input_artifacts    = ["BuildArtifact"]

      configuration = {
        ApplicationName     = "${var.app_name}-codedeploy-app"
        DeploymentGroupName = "${var.app_name}-codedeploy-deployment-group"
      }
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name                  = "${var.app_name}-pipeline-iam-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values   = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "opsworks:CreateDeployment",
      "opsworks:DescribeApps",
      "opsworks:DescribeCommands",
      "opsworks:DescribeDeployments",
      "opsworks:DescribeInstances",
      "opsworks:DescribeStacks",
      "opsworks:UpdateApp",
      "opsworks:UpdateStack",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudformation:ValidateTemplate",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeImages",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "pipeline" {
  name        = "${var.app_name}-codepipeline-iam-policy"
  description = "${var.app_name}-codepipeline-iam-policy"
  policy      = data.aws_iam_policy_document.pipeline.json
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.pipeline.arn
}

resource "aws_s3_bucket" "pipeline" {
  bucket              = var.pipeline_bucket
  force_destroy = true

}


# event bridge
resource "aws_cloudwatch_event_rule" "this" {
  name = "${var.app_name}-event-bridge-rule"

  event_pattern = jsonencode({
    "source": ["aws.codecommit"],
    "detail-type": ["CodeCommit Repository State Change"],
    "resources": ["arn:aws:codecommit:${var.region}:${data.aws_caller_identity.self.account_id}:${var.app_name}-codecommit-repository"],
    "detail": {
      "event": ["referenceCreated", "referenceUpdated"],
      "referenceType": ["branch"],
      "referenceName": ["main"]
    }
  })
}

resource "aws_cloudwatch_event_target" "this" {
  rule     = aws_cloudwatch_event_rule.this.name
  arn      = aws_codepipeline.this.arn
  role_arn = aws_iam_role.event_bridge.arn
}

resource "aws_iam_role" "event_bridge" {
  name               = "${var.app_name}-event-bridge-role"
  assume_role_policy = data.aws_iam_policy_document.event_bridge_assume_role.json

}

data "aws_iam_policy_document" "event_bridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "invoke_codepipeline" {
  name        = "EventBridge_Invoke_CodePipeline_Policy"
  description = "Policy to allow EventBridge to invoke CodePipeline"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "codepipeline:StartPipelineExecution"
      ],
      Resource = "${aws_codepipeline.this.arn}"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.event_bridge.name
  policy_arn = aws_iam_policy.invoke_codepipeline.arn
}



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.app_name}-vpc"
  cidr = var.vpc_cidr_block

  azs             = var.subnet_azs
  public_subnets  = var.public_subnet_cidr_block
}

module "vote_service_sg" {
  source   = "terraform-aws-modules/security-group/aws"
  for_each = var.security_groups

  name        = "${var.app_name}-${each.value.name}-sg"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = each.value.ingress_cidr_blocks
  ingress_with_cidr_blocks = [
    {
      from_port   = each.value.ingress_with_cidr_blocks.from_port
      to_port     = each.value.ingress_with_cidr_blocks.to_port
      protocol    = each.value.ingress_with_cidr_blocks.protocol
      description = each.value.ingress_with_cidr_blocks.description
    }
  ]
  egress_cidr_blocks = each.value.egress_cidr_blocks
  egress_with_cidr_blocks = [
    {
      from_port   = each.value.egress_with_cidr_blocks.from_port
      to_port     = each.value.egress_with_cidr_blocks.to_port
      protocol    = each.value.egress_with_cidr_blocks.protocol
      description = each.value.egress_with_cidr_blocks.description
    }
  ]
}

module "iam_assumable_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  role_requires_mfa = false
  create_role       = true
  role_name         = "${var.app_name}-ec2-role"

  create_instance_profile = true
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]
}

module "ec2_server" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = var.server_instances_map

  name          = "${var.app_name}-ec2"
  instance_type = each.value.instance_type

  iam_instance_profile   = module.iam_assumable_role.iam_instance_profile_name
  vpc_security_group_ids = [module.vote_service_sg["public"].security_group_id]
  subnet_id              = module.vpc.public_subnets[tonumber(each.key)]

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  user_data                   = each.value.user_data
}
