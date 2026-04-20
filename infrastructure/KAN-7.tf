variable "bucket_name" {
  default     = "your-unique-bucket-name" # Replace with your preferred unique name for the S3 bucket
  description = "The name of the new AWS S3 bucket."
}

resource "aws_s3_bucket" "main_storage" {
  bucket_name = var.bucket_name
  
  versioning {
    enabled = true
  }

  tags = {
    ManagedBy       = "AI-Orchestrator"
    Project         = "Jira-Automation"
  }
}