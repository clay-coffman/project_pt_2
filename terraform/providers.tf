terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Credentials come from ~/.aws/credentials (the Learner Lab access key, secret,
  # and session token). The AWS SDK picks up the session token on its own, so
  # there's nothing to put here.
}
