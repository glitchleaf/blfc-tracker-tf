resource "random_password" "redis_password" {
  length  = 50
  special = false
}

resource "aws_elasticache_serverless_cache" "tracker" {
  engine               = "valkey"
  name                 = "tracker"
  description          = "Used by Tracker to store session info"
  kms_key_id           = aws_kms_key.tracker.arn
  major_engine_version = "7"
  security_group_ids   = [aws_security_group.redis_tracker.id]
  subnet_ids           = data.aws_subnets.public.ids
  user_group_id        = aws_elasticache_user_group.tracker.id

  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 1000
    }
  }
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
  from_port                    = aws_elasticache_serverless_cache.tracker.endpoint[0].port
  to_port                      = aws_elasticache_serverless_cache.tracker.endpoint[0].port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tracker.id
  description                  = "Allow the Tracker security group in"
}
