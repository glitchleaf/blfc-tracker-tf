resource "aws_ecs_service" "tracker" {
  # checkov:skip=CKV_AWS_333:Public address is intentional because it lets me avoid paying for a NAT Gateway
  name                   = "tracker"
  cluster                = module.ecs_cluster.name
  task_definition        = aws_ecs_task_definition.tracker.arn
  desired_count          = var.lb_zones > 1 ? var.task_count : 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  # give the nginx container a second to setup its certs
  health_check_grace_period_seconds = 30

  dynamic "load_balancer" {
    for_each = module.alb_tracker

    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = "nginx"
      container_port   = 443
    }
  }

  network_configuration {
    subnets          = var.lb_zones > 0 ? local.lb_subnets : data.aws_subnets.public.ids
    security_groups  = [aws_security_group.tracker.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "tracker" {
  name        = "tracker"
  description = "Allows Tracker to talk to things like SSM, redis, and postgres"
  vpc_id      = data.aws_vpc.resolved.id
}

resource "aws_vpc_security_group_ingress_rule" "tracker_ingress_alb" {
  count                        = var.lb_zones > 0 ? 1 : 0
  security_group_id            = aws_security_group.tracker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.alb_tracker[0].security_group_id
  description                  = "Allow requests in"
}


resource "aws_vpc_security_group_ingress_rule" "tracker_ingress_wan" {
  count             = var.lb_zones == 0 ? 1 : 0
  security_group_id = aws_security_group.tracker.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow requests in"
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
