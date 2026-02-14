locals {
  prefix = "nebatn" # Your unique project nickname
}

provider "aws" {
  region = var.aws_region
}

# 1. SQS Queue for CSV Processing
module "sqs" {
  source     = "../../modules/sqs"
  queue_name = "${var.aws_region}-csv-queue"
}

# 2. S3 Bucket: CSV Files
module "s3_csv" {
  source      = "../../modules/s3"
  bucket_name = "${local.prefix}-${var.aws_region}-csv"
  environment = var.environment
}

# 3. S3 Bucket: Receipts
module "s3_receipts" {
  source      = "../../modules/s3"
  bucket_name = "${local.prefix}-${var.aws_region}-receipts"
  environment = var.environment
}
