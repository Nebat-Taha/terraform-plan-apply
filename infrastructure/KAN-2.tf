variable "bucket_name" {
  default     = "my-s3-bucket-for-jira-automation"
  description = "The name of the S3 bucket to create."
}

resource "aws_s3_bucket" "main_storage" {
  bucket = var.bucket_name
  
  versioning {
    enabled = true
  }

  tags = {
    ManagedBy      = "AI-Orchestrator"
    Project        = "Jira-Automation"
  }
}