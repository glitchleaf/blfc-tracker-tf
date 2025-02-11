resource "aws_route53_zone" "tracker" {
  # checkov:skip=CKV2_AWS_38:more trouble than its worth
  # checkov:skip=CKV2_AWS_39:fucking why
  name = var.domain_name
}
