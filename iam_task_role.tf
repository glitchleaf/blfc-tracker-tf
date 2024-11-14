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
