terraform {
  backend "remote" {
    workspaces {
      prefix = "goblfc-tracker-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  default_tags {
    tags = {
      Terraformed = "true"
      Product     = "tracker"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
