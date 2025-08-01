terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.37.0"
    }
  }
  backend "s3" {
    //Backend configuration will be overridden by --backend-config
  }
}

provider "aws" {
  region = local.config.region
  assume_role {
    role_arn = local.config.assume_role
  }
}