data "aws_elb_service_account" "main" {}

resource "random_id" "logs_bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "logs" {
  # not really relevant for short lived logs
  #checkov:skip=CKV2_AWS_62:ditto
  #checkov:skip=CKV_AWS_144:ditto
  #checkov:skip=CKV_AWS_145:ditto
  #checkov:skip=CKV_AWS_18:ditto
  #checkov:skip=CKV_AWS_21:ditto
  bucket = "logs-${random_id.logs_bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
  #checkov:skip=CKV_AWS_300:checkov is dumb and can;t tell this is set
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "lb-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 2
    }

    filter {
      prefix = aws_lb.tracker.access_logs[0].prefix
    }

    expiration {
      days = var.lb_logs_retention_days
    }
  }
}
