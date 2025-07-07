# Configuration for the S3 Backend to store the Terraform state

terraform {
  backend "s3" {
    bucket         = "dydat-tfstate-milkom121"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
} 