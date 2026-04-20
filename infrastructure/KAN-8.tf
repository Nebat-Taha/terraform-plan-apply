variable "bucket_name" {
  default = "your-unique-bucket-name-here" # Replace with your desired bucket name
}

resource "aws_s3_bucket" "main_storage" {
  bucket = var.bucket_name
  
  versioning {
    enabled = true
  }
  
  tags = {
    ManagedBy     = "AI-Orchestrator"
    Project       = "Jira-Automation"
  }
}
