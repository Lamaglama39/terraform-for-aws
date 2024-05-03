data "aws_caller_identity" "self" { }

# code pipeline
resource "aws_codepipeline" "this" {
  name           = "${var.app_name}-codepipeline" 
  role_arn       = aws_iam_role.pipeline.arn
  pipeline_type  = var.pipeline_type
  execution_mode = var.execution_mode

  artifact_store {
    location = var.pipeline_bucket
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
