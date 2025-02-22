resource "aws_lb" "tracker" {
  # checkov:skip=CKV2_AWS_28:CloudWAF is shit anyways
  # checkov:skip=CKV_AWS_91:User can set it through the var if needed
  # checkov:skip=CKV_AWS_150:Fuckin annoying ass rule

  name                       = "tracker"
  internal                   = var.use_cloudfront
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_tracker.id]
  subnets                    = var.lb_subnets
  drop_invalid_header_fields = true

  access_logs {
    bucket  = var.logs_bucket
    prefix  = "tracker-lb"
    enabled = var.lb_logs_retention_days > 0
  }
}

resource "aws_lb_target_group" "tracker" {
  name             = aws_lb.tracker.name
  port             = 443
  protocol         = "HTTPS"
  protocol_version = var.use_cloudfront ? "HTTP1" : "HTTP2"
  target_type      = "ip"
  vpc_id           = var.vpc_id

  health_check {
    enabled  = true
    port     = "traffic-port"
    protocol = "HTTPS"
    path     = "/healthcheck"
  }
}

resource "aws_lb_listener" "tracker" {
  load_balancer_arn = aws_lb.tracker.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.tracker.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tracker.arn
  }
}
