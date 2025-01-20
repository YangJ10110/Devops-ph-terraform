

# Terraform AWS EC2 Instances

This project uses Terraform to provision 5 EC2 instances on AWS.

## Prerequisites

- Terraform installed
- AWS CLI configured

## Terraform Configuration

The Terraform configuration is defined as follows:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "web-server" {
  ami = "ami-06ca3ca175f37dd66"
  instance_type = "t2.micro"
  count = 5
  tags = {
    Name = "web-server-${count.index}"
  }
}
```

## Steps to Deploy

1. Initialize the Terraform configuration:
   ```sh
   terraform init
   ```

2. Apply the Terraform configuration:
   ```sh
   terraform apply
   ```

## Video Tutorial

This project is based on the following video tutorial: [Terraform AWS EC2 Instances](https://www.youtube.com/watch?v=_PD4j5Ra3kY)

## Known Issues

- If your AWS CLI is configured for a different region (e.g., `ap-southeast-1`) and Terraform is set to `us-east-1`, you may encounter issues with AWS CLI commands such as `aws ec2 describe-instances`. Ensure that both the AWS CLI and Terraform are configured for the same region.

```bash
aws configure
Default region name [x]: us-east-1
```
