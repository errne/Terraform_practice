# PROVIDER
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

# backend
terraform {
  backend "s3" {
    bucket = "sceptre-testing-buck"
    key = "aws/s3"
    region = "eu-west-1"
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-module-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }

}
