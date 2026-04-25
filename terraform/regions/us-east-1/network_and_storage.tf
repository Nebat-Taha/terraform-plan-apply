variable "region" { default = "us-east-1" }

provider "aws" { region = var.region }

resource "aws_default_vpc" {}

data "aws_availability_zones" "available" { count = "${length(var.subnet_configuration)}/2" mincount = 1 }

resource "aws_subnets" "public" { for each in var.subnet_configuration; count = length(each["AZ"]) - 1; subnet_id    = unique_for_az("${var.vpc_name}-aub-sb-PublicSubnet", data.aws_availability_zones.available[count.index]) }

resource "aws_route5e...