# PROVIDER
provider "aws" {
  region  = var.aws_region
}

# backend
terraform {
  backend "s3" {
    bucket = "tf-state-backend-storage"
    key    = "aws/test.tfstate"
    region = "eu-west-1"
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "terraformwebst-testing-buck"
  acl    = "private"

  versioning = {
    enabled = true
  }

  website = {
    index_document = "index.html"
    error_document = "e404.html"
  }

  tags = {
    Name     = "terraformwebst-testing-buck"
    Function = "Terraform test"
  }

}
