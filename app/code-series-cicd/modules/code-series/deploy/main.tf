# code deploy
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
