data "aws_caller_identity" "current" {}

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = local.create_bus

  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = local.schedule_expression
    }
  }

  targets = {
    crons = [
      {
        name = "${local.app_name}-eventbridge"
        arn  = module.lambda.lambda_function_arn
      }
    ]
  }
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name          = "${local.app_name}-lambda"
  description            = "${local.app_name}-lambda"
  handler                = local.handler_name
  architectures          = local.architectures
  ephemeral_storage_size = local.ephemeral_storage_size
  memory_size            = local.memory_size
  layers                 = local.layers

  runtime     = local.runtime
  source_path = local.source_path
  timeout     = local.timeout

  allowed_triggers = {
    Events = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns.crons
    }
  }

  create_current_version_allowed_triggers = false
  attach_policy_statements                = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:*"],
      resources = ["arn:aws:dynamodb:${local.region}:${data.aws_caller_identity.current.account_id}:table/*"]
    }
  }

  environment_variables = local.environment_variables
  tracing_mode          = "PassThrough"

  tags = {
    Name = "${local.app_name}-lambda"
  }
}

module "aws_dynamodb_table_day" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${local.app_name}-dynamodb-day-table"
  billing_mode   = local.billing_mode
  read_capacity  = local.read_capacity
  write_capacity = local.write_capacity
  hash_key       = local.hash_key

  attributes = [
    {
      name = local.attributes_name
      type = local.attributes_type
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}

resource "aws_dynamodb_table_item" "item_day" {
  for_each = local.config_day

  table_name = module.aws_dynamodb_table_day.dynamodb_table_id
  hash_key   = local.hash_key

  item = jsonencode(each.value)
}

module "aws_dynamodb_table_week" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${local.app_name}-dynamodb-week-table"
  billing_mode   = local.billing_mode
  read_capacity  = local.read_capacity
  write_capacity = local.write_capacity
  hash_key       = local.hash_key

  attributes = [
    {
      name = local.attributes_name
      type = local.attributes_type
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}

resource "aws_dynamodb_table_item" "item_week" {
  for_each = local.config_week

  table_name = module.aws_dynamodb_table_week.dynamodb_table_id
  hash_key   = local.hash_key

  item = jsonencode(each.value)
}
