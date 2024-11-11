terraform {
  backend "remote" {
    organization = var.hcp_org
    workspace {
      name = var.hcp_workspace
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Product = "tracker"
    }
  }
}
