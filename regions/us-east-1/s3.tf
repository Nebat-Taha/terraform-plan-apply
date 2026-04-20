variable "bucket_name" {
  default = ""
}

locals {
  bucket_names = ["main_storage"]
}

resource "aws_s3_bucket" "example" {
  bucket = local.bucket_names[count.index] # using count to create multiple buckets if necessary, e.g., for different projects or regions
  
  versioning {
    enabled = true
  }

  tags = {
    ManagedBy       = "AI-Orchestrator"
    Project         = "Jira-Automation"
  }
}