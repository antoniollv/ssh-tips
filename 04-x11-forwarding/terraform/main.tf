terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key            = "ssh-tips/case03-x11-forwarding/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ssh-tips"
      Case        = "03-x11-forwarding"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
