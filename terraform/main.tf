terraform {
  required_version = ">= 1.0"
  
  # Modern cloud backend configuration for Scalr
  cloud {
    hostname     = "dsppun.scalr.io"
    organization = "env-v0oqq3rdbegqlo1ho"
    workspaces {
      name = "aws_s3_bucket_example"
    }
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider configuration
provider "aws" {
  region = var.aws_region
  
  # If using Scalr provider configurations, these are injected automatically
  # Otherwise, configure AWS credentials via environment variables or IAM roles
}

# Create S3 bucket with unique naming
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"
    Environment = var.environment
    ManagedBy   = "Terraform"
    ScalrDemo   = "true"
    CreatedAt   = timestamp()
  }
}

# Generate random suffix for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
