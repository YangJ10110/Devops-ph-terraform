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

provider "aws" {
    region = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true

    access_key = "test"
    secret_key = "test"

    endpoints {
        ec2 = "http://localhost:4566"
        elb = "http://localhost:4566"
        route53 = "http://localhost:4566"
    }

}

module "web-server-1" {
    source = "../web-app-module"

    #input variables
    # Input Variables
    bucket_prefix    = "web-server-1-data"
    domain           = "devopsPH.com"
    app_name         = "web-server-1"
    environment_name = "production"
    instance_type    = "t2.micro"
    create_dns_zone  = true
}

module "web-server-2" {
    source = "../web-app-module"

    #input variables
    # Input Variables
    bucket_prefix    = "web-server-2-data"
    domain           = "devopsPH.com"
    app_name         = "web-server-2"
    environment_name = "production"
    instance_type    = "t2.micro"
    create_dns_zone  = true
}