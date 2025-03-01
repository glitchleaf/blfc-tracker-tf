resource "aws_ecs_task_definition" "tracker" {
  family                   = "tracker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.tracker_spec_cpu
  memory                   = var.tracker_spec_memory
  execution_role_arn       = aws_iam_role.tracker_execution.arn
  task_role_arn            = aws_iam_role.tracker_task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode(concat(
    [
      {
        name      = "nginx"
        image     = "${var.tracker_image}-nginx:latest"
        essential = true
        portMappings = [{
          containerPort = 443
        }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.tracker.name
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = "nginx"
          }
        }
        environment = [
          { name = "NGINX_HOST", value = var.domain_name },
          { name = "NGINX_PORT", value = "443" },
        ]
        entryPoint = ["/usr/bin/bash", "-c"]
        // ugly but vaguely less shit than the alternatives that come to mind
        command = ["echo '${local.nginx_bootscript_b64}' | base64 -d | exec bash"]
      },
      {
        name      = "tracker"
        image     = "${var.tracker_image}:latest"
        essential = true
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.tracker.name
            "awslogs-region"        = data.aws_region.current.name
            "awslogs-stream-prefix" = "tracker"
          }
        }
        environment = [
          { name = "APP_URL", value = "https://${var.domain_name}" },
          { name = "CACHE_STORE", value = "redis" },
          { name = "CONCAT_BASE_URI", value = var.concat_base_uri },
          { name = "DB_CONNECTION", value = "pgsql" },
          { name = "MAILER_FROM_ADDRESS", value = var.smtp_email },
          { name = "MAILER_FROM_NAME", value = var.smtp_name },
          { name = "MAIL_MAILER", value = "smtp" },
          { name = "QUEUE_CONNECTION", value = "redis" },
        ]
        secrets = [
          { name = "APP_KEY", valueFrom = aws_ssm_parameter.manual_secrets["APP_KEY"].arn },
          { name = "CONCAT_CLIENT_ID", valueFrom = aws_ssm_parameter.manual_secrets["CONCAT_CLIENT_ID"].arn },
          { name = "CONCAT_CLIENT_SECRET", valueFrom = aws_ssm_parameter.manual_secrets["CONCAT_CLIENT_SECRET"].arn },
          { name = "DB_URL", valueFrom = aws_ssm_parameter.DB_URL.arn },
          { name = "MAILER_HOST", valueFrom = aws_ssm_parameter.manual_secrets["MAILER_HOST"].arn },
          { name = "MAILER_PASSWORD", valueFrom = aws_ssm_parameter.manual_secrets["MAILER_PASSWORD"].arn },
          { name = "MAILER_PORT", valueFrom = aws_ssm_parameter.manual_secrets["MAILER_PORT"].arn },
          { name = "MAILER_USERNAME", valueFrom = aws_ssm_parameter.manual_secrets["MAILER_USERNAME"].arn },
          { name = "REDIS_URL", valueFrom = aws_ssm_parameter.REDIS_URL.arn },
          { name = "TELEGRAM_BOT_TOKEN", valueFrom = aws_ssm_parameter.manual_secrets["TELEGRAM_BOT_TOKEN"].arn },
        ]
        entryPoint = ["/usr/bin/bash", "-c"]
        command    = ["echo '${local.tracker_bootscript_b64}' | base64 -d | exec bash"]
      }
    ],
    # if there's no load balancer we need something to point our DNS at our ECS task
    var.lb_zones > 0 ? [] : [{
      name      = "dns-updater"
      image     = "amazon/aws-cli"
      essential = false
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.tracker.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "dns-updater"
        }
      }
      entryPoint = ["/usr/bin/bash", "-c"]
      command    = ["echo '${local.dns_bootscript_b64}' | base64 -d | exec bash"]
    }]
  ))
}

resource "aws_cloudwatch_log_group" "tracker" {
  # checkov:skip=CKV_AWS_338:the user can configure that long if they want it
  name              = "ecs.tracker"
  retention_in_days = var.ecs_logs_retention_days
  kms_key_id        = aws_kms_alias.tracker.arn
}
