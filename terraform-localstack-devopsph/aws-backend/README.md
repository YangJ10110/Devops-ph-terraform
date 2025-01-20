# Terraform Configuration with LocalStack

This Terraform configuration is designed to work with **LocalStack** for simulating AWS services locally. It includes the setup for an S3 bucket and DynamoDB table for Terraform state management, with server-side encryption and versioning enabled.

## Required Providers

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
```

## AWS Provider Configuration

The configuration sets the provider to `aws`, pointing to LocalStack endpoints for S3 and DynamoDB. It uses a fake access key and secret key as LocalStack doesn't require real AWS credentials.

### Key Changes:
- **S3 and DynamoDB endpoints** are updated to work with LocalStack. They are set to:
  - `http://s3.localhost.localstack.cloud:4566`
  - `http://dynamodb.localhost.localstack.cloud:4566`

This change is necessary because the default `http://localhost:4566` endpoint does not work with LocalStack services.

```hcl
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
```

## Resources Configuration

### S3 Bucket for Terraform State

The following configuration creates an S3 bucket, `devops-training-tf-state`, for storing Terraform state files. The bucket is set to allow destruction and versioning is enabled.

```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "devops-training-tf-state" # REPLACE WITH YOUR BUCKET NAME
  force_destroy = true
}
```

### S3 Bucket Versioning

This resource enables versioning on the S3 bucket to ensure that multiple versions of the Terraform state can be maintained.

```hcl
resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### S3 Bucket Encryption

This resource configures server-side encryption for the S3 bucket, using the `AES256` encryption algorithm.

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### DynamoDB Table for Terraform Locking

A DynamoDB table named `terraform-state-locking` is created for managing state locking during Terraform operations.

```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

## Important Note

It is essential to use the following endpoints for LocalStack to work correctly:

```hcl
s3        = "http://s3.localhost.localstack.cloud:4566"
dynamodb  = "http://dynamodb.localhost.localstack.cloud:4566"
```

**This configuration only worked after updating the endpoints** from:

```hcl
s3        = "http://localhost:4566"
dynamodb  = "http://localhost:4566"
```

## Conclusion

This setup should allow you to simulate AWS services like S3 and DynamoDB locally for Terraform state management using LocalStack.