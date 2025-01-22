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

    access_key = "test"
    secret_key = "test"

    endpoints {
        ec2 = "http://localhost:4566"
        elb = "http://localhost:4566"
        route53 = "http://localhost:4566"
    }
}

resource "aws_security_group" "web-app-localstack-sg" {
    name = "web-app-localstack-sg"

    ingress {
        from_port   = 8000
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Allowing all IPs to access port 8000
    }
}

resource "aws_instance" "web-server" {
    ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web-app-localstack-sg.name] # Reference security group by name
    tags = {
        Name = "web-server-1"
    }
    user_data = <<-EOF
        #!/bin/bash
        echo "DEVOPS PH # 1" > index.html
        nohup busybox httpd -f -p 80 &
    EOF
}
