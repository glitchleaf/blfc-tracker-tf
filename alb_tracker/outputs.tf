output "security_group_id" {
  value = aws_security_group.alb_tracker.id
}

output "target_group_arn" {
  value = aws_lb_target_group.tracker.arn
}
