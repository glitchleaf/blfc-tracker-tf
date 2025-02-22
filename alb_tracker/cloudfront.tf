resource "aws_cloudfront_vpc_origin" "tracker" {
  count = var.use_cloudfront ? 1 : 0

  vpc_origin_endpoint_config {
    name                   = "tracker-vpc"
    arn                    = aws_lb.tracker.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "https-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}

resource "aws_cloudfront_distribution" "tracker" {
  count = var.use_cloudfront ? 1 : 0

  origin {
    origin_id   = "tracker-alb"
    domain_name = var.domain_name
    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.tracker[0].id
    }
  }

  enabled = true
  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "tracker-alb"
    cache_policy_id        = aws_cloudfront_cache_policy.tracker[0].id
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront[0].arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_cache_policy" "tracker" {
  count = var.use_cloudfront ? 1 : 0

  name        = "tracker"
  min_ttl     = 0
  default_ttl = 3600
  max_ttl     = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = ["example"]
      }
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
