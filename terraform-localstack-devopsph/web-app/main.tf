terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
      backend "s3" {
      bucket         = "devops-training-tf-state" # REPLACE WITH YOUR BUCKET NAME
      key            = "terraform/state"
      region         = "us-east-1"
      endpoint       = "http://localhost:4566"
      skip_credentials_validation = true
      skip_metadata_api_check = true
      skip_requesting_account_id = true
      dynamodb_table = "terraform-state-locking"
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


resource "aws_instance" "web-server-1" {
  ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type = "t2.micro"
    security_groups = [aws_security_group.web-app-localstack-sg.id]
    tags = {
        Name = "web-server-1"
        }
    user_data = <<-EOF
        #!/bin/bash
        echo "DEVOPS PH # 1" > index.html
        nohup busybox httpd -f -p 80 &
    EOF
    
}

resource "aws_instance" "web-server-2" {
    ami = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web-app-localstack-sg.id]
    tags = {
        Name = "web-server-2"
        }
    user_data = <<-EOF
        #!/bin/bash
        echo "DEVOPS PH # 2!" > index.html
        nohup busybox httpd -f -p 80 &
    EOF
    
}


#TODO: ELB
# Reference VPC directly
resource "aws_lb" "web-app-localstack-elb" {
    name                 = "web-app-localstack-elb"
    load_balancer_type   = "application"
    security_groups      = [aws_security_group.alb-localstack-sg.id]  # Attach correct security group here
    subnets              = [aws_subnet.mock_subnet.id]
    enable_deletion_protection = false

    tags = {
        Name = "web-app-localstack-elb"
    }
}


resource "aws_lb_listener" "web-app-localstack-elb-listener" {
    load_balancer_arn = aws_lb.web-app-localstack-elb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "Hello, THIS IS DEVOPS PH!"
            status_code = "200"
        }
        target_group_arn = aws_lb_target_group.web-app-localstack-tg.arn
    }
}

resource "aws_lb_target_group" "web-app-localstack-tg" {
    name     = "web-app-localstack-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.mock_vpc.id  # Use mock VPC ID
    health_check {
        path                = "/"
        port                = "80"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = 3
        interval            = 30
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group_attachment" "web-server-1" {
    target_group_arn = aws_lb_target_group.web-app-localstack-tg.arn
    target_id = aws_instance.web-server-1.id
    port = 80
}

resource "aws_lb_target_group_attachment" "web-server-2" {
    target_group_arn = aws_lb_target_group.web-app-localstack-tg.arn
    target_id = aws_instance.web-server-2.id
    port = 80
}

resource "aws_lb_listener_rule" "instances" {
    listener_arn = aws_lb_listener.web-app-localstack-elb-listener.arn  # Ensure the correct listener ARN
    priority     = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.web-app-localstack-tg.arn
    }
}



resource "aws_vpc" "mock_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "mock-vpc"
    }
}


resource "aws_subnet" "mock_subnet" {
    vpc_id            = aws_vpc.mock_vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "mock-subnet"
    }
}


resource "aws_security_group" "web-app-localstack-sg" {
    name = "web-app-localstack-sg"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.web-app-localstack-sg.id
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "alb-localstack-sg" {
    name = "alb-localstack-sg"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb-localstack-sg.id
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_http_outbound" {
    type = "egress"
    security_group_id = aws_security_group.alb-localstack-sg.id
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_route53_zone" "primary" {
  name = "terraform-training-devops-ph.com"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "terraform-training-devops-ph.com"
  type    = "A"

  alias {
    name                   = aws_lb.web-app-localstack-elb.dns_name
    zone_id                = aws_lb.web-app-localstack-elb.zone_id
    evaluate_target_health = true
  }
}

# dig @localhost terraform-training-devops-ph.webapp.com





