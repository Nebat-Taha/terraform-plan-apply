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

# Instance 1: REDIS
module "redis" {
  source             = "../../modules/ec2"
  ami_id             = "ami-090e1234567890abc" # You can still use your variable from tfvars
  instance_type      = "t2.micro"
  key_name           = module.regional_key_pair.key_pair_name
  subnet_id          = module.vpc_network.app_subnet_id
  security_group_ids = [module.ssh_security_group.security_group_id]

  # Tags
  name_tag        = "${var.aws_region}-redis"
  environment_tag = var.environment
  region_tag      = var.aws_region
  service_name    = "redis"
}

# Instance 2: MONGODB
module "mongodb" {
  source             = "../../modules/ec2"
  ami_id             = "ami-090e1234567890abc" # You can pass a different ID directly
  instance_type      = "t3.medium"             # Or a different size
  key_name           = module.regional_key_pair.key_pair_name
  subnet_id          = module.vpc_network.app_subnet_id
  security_group_ids = [module.ssh_security_group.security_group_id]

  # Tags
  name_tag        = "${var.aws_region}-mongodb"
  environment_tag = var.environment
  region_tag      = var.aws_region
  service_name    = "mongodb"
}
