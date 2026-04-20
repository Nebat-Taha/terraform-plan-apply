variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
}

data "aws_availability_zones" "available" {}

locals {
  s3_bucket_name = "${format("${aws_vpc.main_vpc.id}-", local.random_string)}-myuniquestoragebucket"
}

resource "aws_s3_bucket" "unique_storage" {
  bucket_prefix    = aws_vpc.main_vpc.id
  name             = local.s3_bucket_name
  force_destroy   = true
  versioning      = "Enabled"
}

variable "random_string" {
  default = substr(format("%08x", random()*16^7), 1, 4)
}