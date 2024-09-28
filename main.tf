# Provider configuration
provider "aws" {
  region = "eu-central-1"  # Specifies the AWS region where resources will be created
}

# Terraform state backend configuration
terraform {
  backend "s3" {
    bucket  = "rs-school-vital-slepiankou-1"  # Name of the S3 bucket to store Terraform state files
    key     = "terraform/state"               # Path within the S3 bucket where the state file will be stored
    region  = "eu-central-1"                  # AWS region of the S3 bucket for state storage
  }
}

# Resource definition for the S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "rs-school-vital-slepiankou-3"  # Name of the S3 bucket to be created

  tags = {
    Name        = "Source"                # Tag specifying the name of the bucket
    Environment = "Terraform"             # Tag indicating the environment or purpose
  }
}

# Resource for enabling versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id  # References the ID of the bucket defined above

  versioning_configuration {
    status = "Enabled"  # Enables versioning on the S3 bucket to keep historical versions of objects
  }
}
