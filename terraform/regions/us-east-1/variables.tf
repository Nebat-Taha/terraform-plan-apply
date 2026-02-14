variable "aws_region" {
  type        = string
  description = "The AWS region for deployment"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "ssh_public_key" {
  description = "The actual string starting with ssh-rsa ..."
  type        = string
  sensitive   = true
}
