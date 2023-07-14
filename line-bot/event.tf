resource "aws_cloudwatch_event_rule" "event" {
  event_bus_name      = "default"
  is_enabled          = "true"
  name                = "line_ebvent"
  schedule_expression = "cron(0 21 * * ? *)"
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.event.name
  target_id = "SendTOLambda"
  arn       = aws_lambda_function.lambda.arn
}