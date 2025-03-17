provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "tfstate-bucket-final-unique"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "tfstate-lock-final"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
