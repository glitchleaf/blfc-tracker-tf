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

  enable_nat_gateway = true
  single_nat_gateway = true
  azs                = [for az in data.aws_availability_zones.azs.names : az]
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

resource "aws_vpc_endpoint" "ssm" {
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_id             = data.aws_vpc.resolved.id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpce_ssm.id]

  subnet_ids          = data.aws_subnets.private.ids
  private_dns_enabled = true
}

resource "aws_security_group" "vpce_ssm" {
  name_prefix = "ssm_endpoint"
  vpc_id      = data.aws_vpc.resolved.id
  description = "Allow access from the VPC to the SSM endpoint"
}

resource "aws_vpc_security_group_ingress_rule" "vpce_ssm_ingress" {
  security_group_id = aws_security_group.vpce_ssm.id
  cidr_ipv4         = data.aws_vpc.resolved.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow the VPC in"
}

// TODO: maybe could be scoped, not sure how the communication with concat works yet
resource "aws_vpc_security_group_egress_rule" "vpce_ssm_egress" {
  security_group_id = aws_security_group.vpce_ssm.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow talking to the world"
}
