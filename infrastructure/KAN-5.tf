variable "aws_region" {
  description = "The AWS region where the resources will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for your VPC."
  type        = string
}

variable "public_subnet_count" {
  description = "The number of public subnets to create within the VPC. Must be between 1 and half of total available IP addresses in CIDR minus reserved for other purposes (usually /27 or smaller)."
  type        = number
}

variable "private_subnet_count" {
  description = "The number of private subnets to create within the VPC."
  type        = number
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key // Replace with actual variable if needed, otherwise remove this line for non-interactive sessions using environment variables or shared credentials files.
  secret_key = var.secret_key   // Same as above; ensure these are securely handled in production environments (e.g., through IAM roles).
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true // Enabling DNS hostnames makes it easier to resolve names within the VPC, useful for production environments.
  tags                 = merge(list("ManagedBy=AIO-Orchestrator"), list("Project=Jira-Automation"))
}

// Calculate available IPs and ensure not exceeding /27 or smaller blocks per subnet to maximize efficiency within the VPC CIDR. 
variable "available_ip_count" { // Assuming AWS allows creating at least one public/private pair in a single block for simplicity, otherwise calculate based on actual count of required IPs and available ones after reserving network info like gateway address (usually /24) and DNS records if necessary).
  description = "The number of additional calculated subnet CIDR blocks to create within the VPC."
}

// Define a loop or repeat block for creating multiple public/private pairs. Assuming they share same CIDR with difference in AZs (Public / Subnet-Private), using Terraform 0.12+ syntax without count_index, as this is quite complex and could lead to errors if not handled carefully:
resource "aws_internet_gateway" "main" {
  vpc_id      = aws_vpc.main.id
}

count     = var.public_subnet_count // Number of public subnets needed, assumes an equal count to private for simplicity; adjust as necessary based on the real distribution requirement or automate this with additional variables and logic if needed.
cidr_block= element(tolist("${var.available_ip_count}"), 0) // Just a placeholder assuming first available IP block matches public/private pair, could loop through to find matching blocks for each subnet type in reality based on actual requirements; again adjust as necessary or further abstract with additional variables and logic if needed.
route_table_id      = aws_default_route_table.public-rtrs[0].id // Assuming a single route table exists, replaceable to point explicitly at the right one for public subnets in real scenarios; this simplifies it but can be adjusted based on actual network design requirements or AWS best practices if needed.
associate_with_main_route_table = true // Ensuring association with main VPC's default route table, as we are using the first one here for simplicity and demonstration purposes only; always consider isolating public/private subnet routing in production environments where necessary to reduce exposure of private resources.
name           = "public-rtr${count.index}" // Placeholder naming convention assuming this is a simple setup without more advanced tagging or identification needs, adjust based on actual requirements for clarity and manageability; ideally using Terraform 12+ scoping functions like `cidrsubnet` to create subnets within the loop if needed as well.

resource "aws_route" {
  route_table_id      = aws_internet_gateway.main[0].attachment_id -> attaches this Route Table resource with respective Internet Gateway; assumes a single attachment point for simplicity, ensure to adjust based on actual AWS infrastructure and best practices in production environments if needed: use `aws_route` without count index as it does not require iteration (should be used within resources that benefit from the same configuration across multiple instances).
  destination_cidr = "0.0.00.0/0" // Setting a default route to anywhere outside VPC for internet access; adjust based on actual requirements or security considerations if needed, as this can potentially expose more public IPs than necessary in some configurations: `destination` and associated routes should be carefully planned out considering both functionality needs (like reaching the wider Internet) and minimizing unnecessary exposure.
  id                 = "igw-route${count.index}" // Placeholder naming for route, could adopt similar scoping conventions if multiple instances are necessary; this simplifies identification within Terraform's context but can be adjusted based on actual requirements or needs as needed: `name` and associated tags should provide clarity regarding the purpose of each instance in a larger infrastructure setup.
  next_hop_type = "InternetGatewayId" // Associating with AWS internet gateway for outbound access; this simplifies to using ID directly but can be adjusted based on actual network design requirements or best practices if needed, considering factors like VPC peering and additional security considerations that may require custom route tables.
  origin = "CreateRouteTable" // Indicates the source of creation for routing in context with other resources; could use different origins to provide clearer insights within infrastructure management but simplifies this example's focus on primary access requirements: `origin` should reflect actual orchestration flow or state when deploying multiple instances if necessary.
  transitive = true // Enabling route propagation in dependent subnet routes, ensuring that related public and private networks inherit essential routing for internet connectivity; enables cascading of critical configurations across the infrastructure with minimal manual setup as needed: `transitive` should be considered alongside individual resource management to ensure cohesive behavior within a larger networked application or service.
}
