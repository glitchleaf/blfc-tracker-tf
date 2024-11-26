data "aws_availability_zones" "azs" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  count = var.vpc_name == "default" ? 1 : 0

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=caffe1979732bd2771d2c240e6ee7c63dc3f308d"

  name = "default"
  cidr = "10.0.0.0/16"

  enable_nat_gateway = false # no con is making NAT Gateway money lol
  azs                = data.aws_availability_zones.azs.names
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

data "aws_vpc" "resolved" {
  depends_on = [module.vpc]

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.resolved.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.resolved.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}
