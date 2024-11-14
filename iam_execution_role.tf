resource "aws_iam_role" "tracker_execution" {
  name               = "tracker-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "tracker_execution" {
  statement {
    actions   = ["ssm:GetParameters"]
    resources = ["arn:aws:ssm:*:*:parameter/tracker/*"]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.tracker.arn]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.tracker.arn}:log-stream:*"]
  }
}

resource "aws_iam_role_policy" "tracker_execution" {
  name   = aws_iam_role.tracker_execution.name
  role   = aws_iam_role.tracker_execution.name
  policy = data.aws_iam_policy_document.tracker_execution.json
}
