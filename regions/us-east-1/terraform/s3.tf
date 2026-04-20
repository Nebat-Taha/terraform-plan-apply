variable "bucket_name" {
  type = string
}

data "aws_caller_identity" {}

provider "aws" {
  region     = "us-east-1"
  access_key = data.aws_caller_identity.current.access_keys[0]
  secret_key = data.aws_caller_identity.current.secret_keys[0]
}

resource "aws_s3_bucket" "main_storage" {
  bucket = var.bucket_name
  
  lifecycle {
    prevent_destroy = true
  }
  
  versioning {
    enabled = true
  }
  
  tags = {
    ManagedBy     = "AI-Orchestrator"
    Project       = "Jira-Automation"
  }
}