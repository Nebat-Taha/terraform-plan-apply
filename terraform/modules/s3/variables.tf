variable "bucket_name" {
  type        = string
  description = "The unique name of the S3 bucket"
}

variable "environment" {
  type    = string
  default = "prod"
}
