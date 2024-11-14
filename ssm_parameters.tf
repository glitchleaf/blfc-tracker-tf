resource "aws_ssm_parameter" "manual_secrets" {
  for_each = toset(local.manual_secrets)

  name   = "/tracker/${each.key}"
  value  = "replaceme"
  type   = "SecureString"
  key_id = aws_kms_alias.tracker.arn

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "DB_URL" {
  name   = "/tracker/DB_URL"
  value  = local.db_url
  type   = "SecureString"
  key_id = aws_kms_alias.tracker.arn
}

resource "aws_ssm_parameter" "REDIS_URL" {
  name   = "/tracker/REDIS_URL"
  value  = local.redis_url
  type   = "SecureString"
  key_id = aws_kms_alias.tracker.arn
}
