resource "aws_s3_bucket" "main_storage" {
  bucket        = "${var.bucket_name}"
  acl            = "private"
  region         = var.region
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  
  versioning {
    enabled = true
  }
  
  tags = {
    ManagedBy      = "AI-Orchestrator"
    Project        = "Jira-Automation"
    Environment    = var.environment # Assuming this variable is defined for different environments like 'dev', 'test' etc.
    Department     = var.department   # Define variables to handle department names too, if required often used across resources or in conditionals.
  }
}