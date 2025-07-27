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

# Configure bucket versioning
resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "demo_bucket_encryption" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "demo_bucket_pab" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure lifecycle management
resource "aws_s3_bucket_lifecycle_configuration" "demo_bucket_lifecycle" {
  bucket = aws_s3_bucket.demo_bucket.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_INFREQUENT_ACCESS"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Create demo objects
resource "aws_s3_object" "demo_object" {
  bucket  = aws_s3_bucket.demo_bucket.id
  key     = "demo/scalr-demo.txt"
  content = templatefile("${path.module}/templates/demo-content.txt", {
    bucket_name = aws_s3_bucket.demo_bucket.id
    created_at  = timestamp()
    environment = var.environment
  })
  
  tags = {
    Purpose = "Demo"
    Type    = "Documentation"
  }
}

# Create a JSON configuration file
resource "aws_s3_object" "config_object" {
  bucket  = aws_s3_bucket.demo_bucket.id
  key     = "config/bucket-config.json"
  content = jsonencode({
    bucket_name = aws_s3_bucket.demo_bucket.id
    region      = var.aws_region
    environment = var.environment
    features = {
      versioning_enabled = true
      encryption_enabled = true
      lifecycle_enabled  = true
      public_access_blocked = true
    }
    created_timestamp = timestamp()
  })
  content_type = "application/json"
  
  tags = {
    Purpose = "Configuration"
    Type    = "JSON"
  }
}
