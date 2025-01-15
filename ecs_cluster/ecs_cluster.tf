resource "aws_ecs_cluster" "default" {
  name = "default"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
      }
    }

    managed_storage_configuration {
      fargate_ephemeral_storage_kms_key_id = aws_kms_key.ecs.arn
    }
  }

  setting {
    name  = "containerInsights"
    value = var.ecs_container_insights_state
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name       = aws_ecs_cluster.default.name
  capacity_providers = ["FARGATE"]
}
