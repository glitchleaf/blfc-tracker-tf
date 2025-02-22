resource "aws_route53_record" "tracker" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name    = var.use_cloudfront ? aws_cloudfront_distribution.tracker[0].domain_name : aws_lb.tracker.dns_name
    zone_id = var.use_cloudfront ? aws_cloudfront_distribution.tracker[0].hosted_zone_id : aws_lb.tracker.zone_id

    evaluate_target_health = true
  }
}
