resource "aws_s3_bucket" "remote_state" {
  bucket = "devops-ej1"
}

resource "aws_dynamodb_table" "remote-state" {
  name           = "remote-state"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"


  attribute {
    name = "LockID"
    type = "S"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}