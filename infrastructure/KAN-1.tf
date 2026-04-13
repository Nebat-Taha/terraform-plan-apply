variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create."
}

resource "aws_s3_bucket" "main_storage" {
  bucket = var.bucket_name
  
  versioning {
    enabled = true
    
    mfa_delete = false # Commented out as per example output, uncomment if needed for your use case.
  }
}
