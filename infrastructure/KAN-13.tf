variable "region" {

  description = "The AWS region where the resources will be deployed."

  type        = string

  default     = "us-east-1"

}


resource "aws_default_vpc" {}


data "aws_availability_zones" "available" {

  state = "available"

  filter = {

    name   = "optimal-for-me2b"

    values = [var.region]

  }

}


resource "aws_s3_bucket" "main_storage" {

  bucket = "${var.cidr[5:8]}-data" # '172' for CIDR suffix as per requirement, excluding the last octet '-0-' to form a valid name without hyphens and special characters that could be misinterpreted by Terraform or AWS

  region = var.region

  tags    = {

    Project   = "Jira-Automation"

    ManagedBy = "AI-Orchestrator"

  }

}

