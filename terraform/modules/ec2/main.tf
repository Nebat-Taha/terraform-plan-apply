resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name        = var.name_tag
    Environment = var.environment_tag
    Region      = var.region_tag
    service     = var.service_name # Dynamic: redis or mongodb
  }
}
