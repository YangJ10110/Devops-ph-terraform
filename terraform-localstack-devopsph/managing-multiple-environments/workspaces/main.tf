terraform {
  # Assumes s3 bucket and dynamo DB table already set up
  # See /code/03-basics/aws-backend
#   backend "s3" {
#     bucket         = "devops-directive-tf-state"
#     key            = "07-managing-multiple-environments/workspaces/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-locking"
#     encrypt        = true
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment_name = terraform.workspace
}

module "web_app" {
  source = "../../Organizations_and_Modules/web-app-module"

  bucket_prefix    = "web-app-data-${local.environment_name}"
  domain           = "devopsPH.com"
  environment_name = local.environment_name
  instance_type    = "t2.micro"
  create_dns_zone  = terraform.workspace == "production" ? true : false
  dns_zone_id = terraform.workspace == "production" ? data.aws_route53_zone.primary.id : null
}


#C:\Users\Jerome Yang\OneDrive - Mapúa University\Documents\TERA\Devops-ph-terraform\terraform-localstack-devopsph\