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
    # key    = "ssh-tips/02-reverse-tunnel/terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ssh-tips"
      Case        = "02-reverse-tunnel"
      Environment = "demo"
      ManagedBy   = "terraform"
    }
  }
}
