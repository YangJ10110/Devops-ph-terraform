terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
#       backend "s3" {
#       bucket         = "devops-training-tf-state" # REPLACE WITH YOUR BUCKET NAME
#       key            = "terraform/state"
#       region         = "us-east-1"
#       endpoint       = "http://s3.localhost.localstack.cloud:4566"
#       skip_credentials_validation = true
#       skip_metadata_api_check = true
#       skip_requesting_account_id = true
#       dynamodb_table = "terraform-state-locking"
#   }
}
