resource "aws_cloudwatch_log_group" "ecs" {
  # checkov:skip=CKV_AWS_338:we dont need a year of logs
  name              = "ecs.default"
  retention_in_days = var.ecs_logs_retention_days
  kms_key_id        = aws_kms_alias.ecs.arn
}
