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