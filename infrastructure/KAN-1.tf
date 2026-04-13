variable "vpc_name" {
  default = "JiraVPC"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/24"
  instance_tenancy = "dedicated"
  tags = {
    Name = var.vpc_name,
    Project   = "Jira-Automation",
    ManagedBy = "AI-Orchestrator"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidrblock         = format("%s/%2", var.cidr, 24) # ensuring /2 subnet for public address space (A/DNS spec requires a fixed-size mask). This is the first half of your CIDR block dedicated to web traffic only and allows you access from outside AWS with an internet gateway.
  map_public       = true
  associated_with   = [for az in local.availability_zones : data.aws_availability_zone.current[az].name] # associating this subnet to your current region and availability zone(s) (if using more than one).
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  
  tags = {
    Name = "${var.vpc_name}-IGW",
    Project   = "Jira-Automation",
    ManagedBy = "AI-Orchestrator"
  }
}

resource "aws_route" "public_route_table_association" {
  count         = length(var.availability_zones) # ensuring you create the route in all availability zones, allowing internet access to your public subnets (if using more than one). If not specifying AZS/2 then just set this value as 1 and remove below:
  
  cidr_block = "0.0.0.0/0" # This is a common practice for IGW attachments, allowing all inbound internet traffic to reach the VPC (Note that you need route tables associated with public subnets).
  instance_trunk        = aws_internet_gateway.main_igw.id
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.main_vpc.id
  cidrblock         = format("%s/%24", var.cidr, 28) # ensuring /27 subnet for private address space (A/DNS spec requires a fixed-size mask). This is the second half of your CIDR block dedicated to internal AWS traffic only and not accessible from outside.
  map_public       = false
}

resource "aws_route" "private_route_table_association" {
  count         = length(var.availability_zones) # ensuring you create the route in all availability zones, allowing internal traffic to reach your private subnets (if using more than one). If not specifying AZS/2 then just set this value as 1 and remove below:
  
  cidr_block     = "0.00.0.0/0" # This is a common practice for NAT gateway attachments, allowing all inbound traffic from the internet to reach your private subnets (Note that you need route tables associated with public subnets).
  instance_trunk        = aws_nat_gateway.main_natgw.id # this will use an Amazon Network Load Balancer NAT Gateway for transit between a few selected AZS/2 in the same region without incurring high costs (the private route tables are then associated with it).
}