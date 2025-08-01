# Terraform Settings Block
terraform {
  #required_version = "1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.1"
    }
  }

  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "comera-pay-prod-tf-state"
    key    = "network/vpc.tf"
    region = "me-central-1"
  }
}

# Terraform Provider Block
provider "aws" {
  region = var.region
}
