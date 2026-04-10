# Terraform for DEV-404
# Summary: Deploy a managed Kubernetes cluster on AWS
resource "aws_s3_bucket" "example" {
  bucket = "ai-test-bucket-dev-404"
}
