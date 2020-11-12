locals {
  my_function_source = "../../Code_archive/get_one_item_from_ddb.zip"
}

resource "aws_s3_bucket_object" "my_function" {
  bucket = "lambda-code-storage-bucket"
  key    = "${filemd5(local.my_function_source)}.zip"
  source = local.my_function_source
}

module "lambda_function_existing_package_s3" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "get_one_lambda"
  description   = "Lambda function to get one item from specified Dynamo DB table"
  handler       = "get_one_item_from_ddb.lambda_handler"
  runtime       = "python3.7"
  publish       = true

  create_package = false
  s3_existing_package = {
    bucket = "lambda-code-storage-bucket"
    key    = aws_s3_bucket_object.my_function.id
  }

  environment_variables = {
    TABLE_NAME = "clients"
  }

  tags = {
    Name     = "get_one_lambda"
    Language = "Python"
  }
}
