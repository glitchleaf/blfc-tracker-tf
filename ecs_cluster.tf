# there are just a few too many parts specific to the ECS cluster itself, so we
# isolate it to a module.
module "ecs_cluster" {
  source = "./ecs_cluster"

  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
