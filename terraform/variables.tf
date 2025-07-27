variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "scalr-demo-bucket"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_prefix))
    error_message = "Bucket prefix must be lowercase, start and end with alphanumeric characters, and can contain hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "enable_lifecycle" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}
