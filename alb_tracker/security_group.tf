resource "aws_security_group" "alb_tracker" {
  name        = "alb-tracker"
  description = "Allow Tracker ALB to receive traffic"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_tracker_https" {
  for_each = var.ingress_cidrs

  security_group_id = aws_security_group.alb_tracker.id
  cidr_ipv4         = each.key
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow the world to speak HTTPS to us"
}

resource "aws_vpc_security_group_egress_rule" "alb_tracker_backend" {
  security_group_id = aws_security_group.alb_tracker.id
  cidr_ipv4         = var.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow talking HTTPS to whole VPC"
}
