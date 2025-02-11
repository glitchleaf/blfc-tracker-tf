resource "aws_iam_role" "tracker_task" {
  name               = "tracker-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "tracker_task" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [module.ecs_cluster.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "tracker_task" {
  name   = aws_iam_role.tracker_task.name
  role   = aws_iam_role.tracker_task.name
  policy = data.aws_iam_policy_document.tracker_task.json
}

data "aws_iam_policy_document" "dns_update" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [aws_route53_zone.tracker.arn]
  }
}

resource "aws_iam_role_policy" "dns_update" {
  count = var.lb_zones == 0 ? 1 : 0

  name   = "${aws_iam_role.tracker_task.name}-dns-update"
  role   = aws_iam_role.tracker_task.name
  policy = data.aws_iam_policy_document.dns_update.json
}
