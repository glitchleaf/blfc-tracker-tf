output "kms_key_arn" {
  description = "KMS key used to encrypt ephemeral storage, logs, and for ECS exec"
  value       = aws_kms_key.ecs.arn
}

output "name" {
  description = "The clusters name"
  value       = aws_ecs_cluster.default.name
}
