terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to store state remotely in S3 (recommended for team use)
  # backend "s3" {
  #   bucket  = "your-terraform-state-bucket"
  #   key     = "aws-secure-remote-access/terraform.tfstate"
  #   region  = "us-east-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = var.project_name
      Environment = var.environment
      ManagedBy  = "Terraform"
      Repository = "aws-secure-remote-access"
    }
  }
}
