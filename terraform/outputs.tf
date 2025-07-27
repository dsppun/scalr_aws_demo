output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.demo_bucket.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.demo_bucket.arn
}

output "bucket_region" {
  description = "Region of the created S3 bucket"
  value       = aws_s3_bucket.demo_bucket.region
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.bucket_domain_name
}

output "demo_objects" {
  description = "Demo objects created in the bucket"
  value = {
    demo_file   = aws_s3_object.demo_object.key
    config_file = aws_s3_object.config_object.key
  }
}

output "bucket_features" {
  description = "Enabled bucket features"
  value = {
    versioning_enabled = aws_s3_bucket_versioning.demo_bucket_versioning.versioning_configuration[0].status
    encryption_enabled = true
    lifecycle_enabled  = var.enable_lifecycle
    public_access_blocked = true
  }
}
