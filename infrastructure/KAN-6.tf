variable "bucket_name" {
  type        = string
  default     = "jiratasks"
  description = "The name of the S3 bucket to create."
}

resource "aws_s3_bucket" "main_storage" {
  bucket_name      = var.bucket_name
  force_destroy    = true
  acl              = "private"
  versioning {
    enabled   = true
    mfa        = false # Optional: Enable MFA if you have multi-factor authentication set up for the AWS account.
  }
}
