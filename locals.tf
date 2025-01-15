locals {
  # these will be created with an empty default value that you're meant to set
  # manually in AWS.
  manual_secrets = [
    "APP_KEY",
    "CONCAT_CLIENT_ID",
    "CONCAT_CLIENT_SECRET",
    "MAILER_HOST",
    "MAILER_PASSWORD",
    "MAILER_PORT",
    "MAILER_USERNAME",
    "TELEGRAM_BOT_TOKEN",
  ]

  tracker_bootscript_b64 = filebase64("${path.module}/files/tracker_entrypoint.sh")
  nginx_bootscript_b64 = base64encode(templatefile(
    "${path.module}/files/nginx_entrypoint.sh", {
      nginx_conf_template_b64 = filebase64("${path.module}/files/default.conf.template")
    },
  ))

  db_url    = "pgsql://${random_pet.db_user.id}:${random_password.db_password.result}@${aws_db_instance.tracker.endpoint}/${aws_db_instance.tracker.db_name}"
  redis_url = "rediss://${aws_elasticache_user.tracker.user_name}:${random_password.redis_password.result}@${aws_elasticache_replication_group.tracker.primary_endpoint_address}:${aws_elasticache_replication_group.tracker.port}"

  lb_subnets = slice(data.aws_subnets.public.ids, 0, min(length(data.aws_subnets.public.ids), var.lb_zones))
}
