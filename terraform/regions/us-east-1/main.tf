locals {
  prefix = "nebatn" # Your unique project nickname
}

provider "aws" {
  region = var.aws_region
}

#################################
# 1. STORAGE & MESSAGING
#################################

# SQS Queue for CSV Processing
module "sqs" {
  source     = "../../modules/sqs"
  queue_name = "${var.aws_region}-csv-queue"
}

# S3 Bucket: CSV Files
module "s3_csv" {
  source      = "../../modules/s3"
  bucket_name = "${local.prefix}-${var.aws_region}-csv"
  environment = var.environment
}

# S3 Bucket: Receipts
module "s3_receipts" {
  source      = "../../modules/s3"
  bucket_name = "${local.prefix}-${var.aws_region}-receipts"
  environment = var.environment
}

#################################
# 2. NETWORKING & SECURITY
#################################

# Custom VPC Network
module "vpc_network" {
  source                = "../../modules/network"
  vpc_cidr_block        = "10.0.0.0/16"
  app_subnet_cidr_block = "10.0.1.0/24"
  db_subnet_cidr_block  = "10.0.2.0/24"
  aws_region            = var.aws_region
  environment           = var.environment
  az_suffix             = "a"
}

# SSH Security Group for Instance Connect
module "ssh_security_group" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc_network.vpc_id
  sg_name             = "ssh-access"
  sg_description      = "Allow SSH access for EIC"
  allowed_cidr_blocks = ["0.0.0.0/0"]
  environment         = var.environment
  aws_region          = var.aws_region
}

#################################
# 3. COMPUTE INSTANCES
#################################

# Instance 1: REDIS (In App Subnet)
module "redis" {
  source        = "../../modules/ec2"
  ami_id        = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  # Commented out to use EC2 Instance Connect (IAM based)
  # key_name         = module.regional_key_pair.key_pair_name 

  subnet_id          = module.vpc_network.app_subnet_id
  security_group_ids = [module.ssh_security_group.security_group_id]

  name_tag        = "${var.aws_region}-redis"
  environment_tag = var.environment
  region_tag      = var.aws_region
  service_name    = "redis"
}

# Instance 2: MONGODB (In DB Subnet)
module "mongodb" {
  source        = "../../modules/ec2"
  ami_id        = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  # Commented out to use EC2 Instance Connect (IAM based)
  # key_name         = module.regional_key_pair.key_pair_name

  subnet_id          = module.vpc_network.db_subnet_id
  security_group_ids = [module.ssh_security_group.security_group_id]

  name_tag        = "${var.aws_region}-mongodb"
  environment_tag = var.environment
  region_tag      = var.aws_region
  service_name    = "mongodb"
}
