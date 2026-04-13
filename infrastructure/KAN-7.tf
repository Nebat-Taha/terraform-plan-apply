variable "bucket_name" {
  type        = string
  default     = "my-s3-bucket-with-versioning"
}

resource "aws_s3_bucket" "main_storage" {
  bucket_prefix         = var.bucket_name
  versioning_configuration {
    enable       = true
    delete_marker_retention_days = 0 # Retain daily deletion markers if needed for audits, set to zero or remove this setting as per requirements.
  }
  
  tags = {
    "Project"         = var.bucket_name
    "ManagedBy"       = "AI-Orchestrator"
  }
}
