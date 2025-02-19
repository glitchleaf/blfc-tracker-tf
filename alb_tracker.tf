module "alb_tracker" {
  count = var.lb_zones > 1 ? 1 : 0

  source = "./alb_tracker"

  cidr_block             = data.aws_vpc.resolved.cidr_block
  domain_name            = local.tracker_domain
  ingress_cidrs          = var.cloudflare_api_token == "" ? ["0.0.0.0/0"] : module.cloudflare.cidrs
  lb_logs_retention_days = var.lb_logs_retention_days
  lb_subnets             = local.lb_subnets
  logs_bucket            = aws_s3_bucket.logs.id
  vpc_id                 = data.aws_vpc.resolved.id
  zone_id                = aws_route53_zone.tracker.zone_id
}
