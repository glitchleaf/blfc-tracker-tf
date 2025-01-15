resource "aws_lb" "tracker" {
  name                       = "tracker"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_tracker.id]
  subnets                    = local.lb_subnets
  drop_invalid_header_fields = true
  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "tracker-lb"
    enabled = var.lb_logs_retention_days > 0
  }
}

resource "aws_lb_target_group" "tracker" {
  name        = aws_lb.tracker.name
  port        = 443
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.resolved.id

  health_check {
    enabled  = true
    port     = "traffic-port"
    protocol = "HTTP"
    path     = "/healthcheck"
  }
}

resource "aws_lb_listener" "tracker" {
  load_balancer_arn = aws_lb.tracker.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.tracker.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tracker.arn
  }
}

resource "aws_security_group" "alb_tracker" {
  name        = "alb-tracker"
  description = "Allow Tracker ALB to receive traffic"
  vpc_id      = data.aws_vpc.resolved.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_tracker_https" {
  security_group_id = aws_security_group.alb_tracker.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow the world to speak HTTPS to us"
}

resource "aws_vpc_security_group_egress_rule" "alb_tracker_backend" {
  security_group_id = aws_security_group.alb_tracker.id
  cidr_ipv4         = data.aws_vpc.resolved.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow talking to whole VPC"
}
