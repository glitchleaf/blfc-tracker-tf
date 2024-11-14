resource "aws_cloudwatch_log_group" "ecs" {
  name              = "ecs.default"
  retention_in_days = 3
  kms_key_id        = aws_kms_alias.ecs.arn
}
