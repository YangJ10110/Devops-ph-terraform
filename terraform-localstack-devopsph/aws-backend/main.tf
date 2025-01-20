terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  # backend "s3" {
  #     bucket         = "devops-training-tf-state" # REPLACE WITH YOUR BUCKET NAME
  #     key            = "terraform/state"
  #     region         = "us-east-1"
  #     endpoint       = "http://localhost:4566"
  #     skip_credentials_validation = true
  #     skip_metadata_api_check = true
  #     skip_requesting_account_id = true
  #     dynamodb_table = "terraform-state-locking"
  # }
}

provider "aws" {
  region = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true

  access_key = "test"    # Fake access key for LocalStack
  secret_key = "test"    # Fake secret key for LocalStack

  endpoints {
    s3        = "http://s3.localhost.localstack.cloud:4566"
    dynamodb  = "http://dynamodb.localhost.localstack.cloud:4566"
  }
}


resource "aws_s3_bucket" "terraform_state" {
  bucket        = "devops-training-tf-state" # REPLACE WITH YOUR BUCKET NAME
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}