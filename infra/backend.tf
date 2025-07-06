# Configuration for the S3 Backend to store the Terraform state

terraform {
  backend "s3" {
    bucket         = "dydat-tfstate-milkom121"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

# Resource definition for the S3 bucket that will store the state
# We define it here so that Terraform can create it for us.
resource "aws_s3_bucket" "tfstate" {
  bucket = "dydat-tfstate-milkom121"

  # Enable versioning to keep a history of the state files
  versioning {
    enabled = true
  }

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
} 