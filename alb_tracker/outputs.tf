output "dns_name" {
  value = aws_lb.tracker.zone_id
}

output "security_group_id" {
  value = aws_security_group.alb_tracker.id
}

output "target_group_arn" {
  value = aws_lb_target_group.tracker.arn
}

output "zone_id" {
  value = aws_lb.tracker.zone_id
}
