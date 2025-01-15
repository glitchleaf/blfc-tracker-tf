data "aws_elb_service_account" "main" {}

resource "random_id" "logs_bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "logs" {
  bucket = "logs-${random_id.logs_bucket_suffix.hex}"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "logs" {
  # NOTE: if you're in a newer region this'll need to change:
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/*"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "lb-logs"
    status = "Enabled"

    filter {
      prefix = aws_lb.tracker.access_logs[0].prefix
    }

    expiration {
      days = var.lb_logs_retention_days
    }
  }
}
