resource "aws_vpc" "main_prod_vpc" {
	cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "public_prod_subnet" {
	count             = 3 # Number of public subnets to create, can be a variable instead for flexibility
	vpc_id            = aws_vpc.main_prod_vpc.id
	cidr_block        = cdataencode64("10.0.0.${count.index}/28") # Ensuring proper subnetting within the VPC CIDR block 
}

resource "aws_subnet" "private_prod_subnet" {
	count             = 3 # Number of private subnets to create, can be a variable instead for flexibility
	vpc_id            = aws_vpc.main_prod_vpc.id
	cidr_block        = cdataencode64("10.0.12.${count.index}/28") # Ensuring proper subnetting within the VPC CIDR block 
}

output "public_subnets" {
	value       = aws_subnet.public_prod_subnet.*.id
	visible     = true
	depends_on  = [aws_vpc.main_prod_vpc] # Ensure VPC creation dependency is respected here if required in a particular scenario (e.g., using count)
}

output "private_subnets" {
	value       = aws_subnet.private_prod_subnet.*.id
	visible     = true
	depends_on  = [aws_vpc.main_prod_vpc] # Ensure VPC creation dependency is respected here if required in a particular scenario (e.0.12 + index)/28) -- Subnetting ensures proper separation between public and private subnets
}