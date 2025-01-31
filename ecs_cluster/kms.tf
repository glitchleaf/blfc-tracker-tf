resource "aws_kms_key" "ecs" {
  description         = "Used to encrypt ECS logs and Fargate ephemeral storage at rest"
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
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
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

  statement {
    actions   = ["kms:GenerateDataKeyWithoutPlaintext"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["fargate.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:ecs:clusterAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:ecs:clusterName"
      values   = ["default"]
    }
  }

  statement {
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["fargate.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:ecs:clusterAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:ecs:clusterName"
      values   = ["default"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "kms:GrantOperations"
      values   = ["Decrypt"]
    }
  }
}

resource "aws_kms_alias" "ecs" {
  name          = "alias/ecs"
  target_key_id = aws_kms_key.ecs.key_id
}
