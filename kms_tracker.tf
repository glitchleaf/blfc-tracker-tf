resource "aws_kms_key" "tracker" {
  description         = "Used to encrypt SSM params for Tracker"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.tracker_kms.json
}

data "aws_iam_policy_document" "tracker_kms" {
  # checkov:skip=CKV_AWS_109:Is this even possible on a resource policy?
  # checkov:skip=CKV_AWS_111:Silly on a resource policy
  # checkov:skip=CKV_AWS_356:ditto
  statement {
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}

resource "aws_kms_alias" "tracker" {
  name          = "alias/tracker"
  target_key_id = aws_kms_key.tracker.key_id
}
