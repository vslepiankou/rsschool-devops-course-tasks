# Provider configuration
provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket         = "rs-school-vital-slepiankou-1"
    key            = "terraform/state"
    region         = "eu-central-1"
    profile        = "default"
  }
}

# Resource definition for the S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "rs-school-vital-slepiankou-2"

  tags = {
    Name        = "Source"
    Environment = "Terraform"
  }
}

# Resource for enabling versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
