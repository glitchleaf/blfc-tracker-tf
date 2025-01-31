resource "aws_ecs_service" "tracker" {
  #checkov:skip=CKV_AWS_333:Public address is intentional because it lets me avoid paying for a NAT Gateway
  name                   = "tracker"
  cluster                = module.ecs_cluster.name
  task_definition        = aws_ecs_task_definition.tracker.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  # give the nginx container a second to setup its certs
  health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = aws_lb_target_group.tracker.arn
    container_name   = "nginx"
    container_port   = 443
  }

  network_configuration {
    subnets          = local.lb_subnets
    security_groups  = [aws_security_group.tracker.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "tracker" {
  name        = "tracker"
  description = "Allows Tracker to talk to things like SSM, redis, and postgres"
  vpc_id      = data.aws_vpc.resolved.id
}

resource "aws_vpc_security_group_ingress_rule" "tracker_ingress" {
  security_group_id            = aws_security_group.tracker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_tracker.id
  description                  = "Allow the ALB in"
}

// TODO: maybe could be scoped, not sure how the communication with concat works yet
resource "aws_vpc_security_group_egress_rule" "tracker_egress" {
  security_group_id = aws_security_group.tracker.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
  description       = "Allow talking to the world"
}
