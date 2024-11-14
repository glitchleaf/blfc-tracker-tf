resource "aws_route53_zone" "tracker" {
  name = var.domain_name
}

resource "aws_route53_record" "tracker" {
  zone_id = aws_route53_zone.tracker.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.tracker.dns_name
    zone_id                = aws_lb.tracker.zone_id
    evaluate_target_health = true
  }
}
