terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration will be provided via:
    # - GitHub Actions workflow (CI/CD)
    # - terraform init -backend-config (local development)
    # 
    # Required backend config:
    # bucket = "your-terraform-state-bucket"
    # key    = "ssh-tips/04-x11-forwarding/terraform.tfstate"
    # region = "eu-west-1"
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
