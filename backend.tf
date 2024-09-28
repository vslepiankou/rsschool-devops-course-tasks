# Terraform state backend configuration
terraform {
  backend "s3" {
    bucket  = "rs-school-vital-slepiankou-1"  # Name of the S3 bucket to store Terraform state files
    key     = "terraform/state"               # Path within the S3 bucket where the state file will be stored
    region  = var.aws_region                  # AWS region of the S3 bucket for state storage
  }
}