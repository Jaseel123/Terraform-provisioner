terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
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

provider "vault" {
  address = local.config.vault_endpoint
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}
