resource "random_password" "redis_password" {
  length  = 50
  special = false
}

# tflint-ignore:aws_elasticache_replication_group_default_parameter_group
resource "aws_elasticache_replication_group" "tracker" {
  # checkov:skip=CKV2_AWS_50:if we get enough load on redis to justify multi-az we probably need to refactor the whole app
  replication_group_id = "tracker"
  description          = "Used by Tracker to store session info"

  at_rest_encryption_enabled  = true
  auto_minor_version_upgrade  = true
  cluster_mode                = "disabled"
  engine                      = "valkey"
  engine_version              = "7.2"
  kms_key_id                  = aws_kms_key.tracker.arn
  maintenance_window          = "Mon:10:00-Mon:13:00"
  multi_az_enabled            = false
  node_type                   = "cache.t3.micro"
  parameter_group_name        = "default.valkey7"
  port                        = 6379
  preferred_cache_cluster_azs = slice(data.aws_availability_zones.azs.names, 0, 1)
  security_group_ids          = [aws_security_group.redis_tracker.id]
  subnet_group_name           = aws_elasticache_subnet_group.private.name
  transit_encryption_enabled  = true
  user_group_ids              = [aws_elasticache_user_group.tracker.id]
}

resource "aws_elasticache_subnet_group" "private" {
  name        = "private"
  description = "The private subnets"
  subnet_ids  = data.aws_subnets.private.ids
}

resource "aws_elasticache_user" "tracker" {
  user_id       = "tracker"
  user_name     = "default"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords     = [random_password.redis_password.result]
}

resource "aws_elasticache_user_group" "tracker" {
  engine        = "REDIS"
  user_group_id = "tracker"
  user_ids      = [aws_elasticache_user.tracker.user_id]
}

resource "aws_security_group" "redis_tracker" {
  name        = "redis-tracker"
  description = "Allow Tracker to talk to redis"
  vpc_id      = data.aws_vpc.resolved.id
}

resource "aws_vpc_security_group_ingress_rule" "redis_tracker" {
  security_group_id            = aws_security_group.redis_tracker.id
  from_port                    = aws_elasticache_replication_group.tracker.port
  to_port                      = aws_elasticache_replication_group.tracker.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tracker.id
  description                  = "Allow the Tracker security group in"
}
