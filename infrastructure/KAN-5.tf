variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = merge(list("ManagedBy=AI-Orchestrator"), list("Project=Jira-Automation"))
}

resource "aws_subnet" "public_a" {
  count         = 2
  vpc_id         = aws_vpc.main_vpc.id
  cidr_block     = element(["10.0.1.0/24", "10.0.2.0/24"], toindex(count()))
  map_public    = true
  tags           = merge(list("Name=Public-SubnetA"), list("ManagedBy=AI-Orchestrator"))
}

resource "aws_subnet" "private_a" {
  count         = 2
  vpc_id         = aws_vpc.main_vpc.id
  cidr_block     = element(["10.0.3.0/24", "10.0.4.0/24"], toindex(count()))
  map_public    = false
  tags           = merge(list("Name=Private-SubnetA"), list("ManagedBy=AI-Orchestrator"))
}
