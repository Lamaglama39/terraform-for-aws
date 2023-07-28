# Eventbridgeルールの作成
resource "aws_cloudwatch_event_rule" "event" {
  event_bus_name      = "default"
  is_enabled          = "true"
  name                = var.eventbridge_name
  schedule_expression = var.eventbridge_schedule
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.event.name
  target_id = "SendTOLambda"
  arn       = aws_lambda_function.lambda.arn
}