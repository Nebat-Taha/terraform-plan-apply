variable "bucket_name" {

  default = "main-storage" # Replace this with your preferred bucket name prefixed by a dash if you wish to use underscores in resource names instead of camel case naming conventions. Otherwise, keep it simple and direct as per the requirement.

}


resource "aws_s3_bucket" "main_storage" {

  bucket = var.bucket_name

  acl    = "private" # You can also use 'public-read' for different access control requirements if necessary, but do not forget to configure permissions accordingly in your IAM policy documents or via other mechanisms outside of Terraform code (not included here).

}


resource "aws_s3_bucket_versioning" "main_storage" {

  bucket = aws_s3_bucket.main_storage.id # Use the id attribute to reference this specific S3 bucket resource for its versioning configuration because we want these settings applied specifically to that created bucket and not just any other one with a similar name in your account or region.

}


resource "aws_s3_bucket_encryption" "main_storage" {

  bucket = aws_s3_bucket.main_storage.id # Same as above, refer to the created S3 bucket's id for its encryption configuration settings specificity due to Terraform state uniqueness requirements based on resource ID attributes rather than solely name or region/account reference points which can be ambiguous across multiple instances of similar resources in a single script run scenario.

  server_side_encryption_by_default = false # The default setting for serverside encryption is true if unspecified, but since we are explicitly configuring it elsewhere, here just ensure that this block does not conflict with other settings or IAM permissions required to utilize SSE (Server-Side Encryption).

}

