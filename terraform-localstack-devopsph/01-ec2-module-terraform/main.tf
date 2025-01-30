provider "aws" {
    region                      = "us-east-1"
    access_key                  = "mock_access_key"
    secret_key                  = "mock_secret_key"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoints {
        ec2            = "http://localhost:4566"
        iam            = "http://localhost:4566"
        s3             = "http://localhost:4566"
    }
}

module "ec2_instance" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "~> 3.0"

    name           = "my-localstack-instance"
    instance_type  = "t2.micro"
    ami            = "ami-0c55b159cbfafe1f0" # Dummy AMI ID
    key_name       = "my-key"

    vpc_security_group_ids = ["sg-12345678"]
    subnet_id              = "subnet-12345678"

    tags = {
        Name = "LocalStackInstance"
    }

    ebs_block_device = [{
        device_name           = "/dev/sdh" 
        volume_type           = var.ebs_volume.type
        volume_size           = var.ebs_volume.size
        iops                  = var.ebs_volume.iops
        encrypted             = var.ebs_volume.encrypted
        kms_key_id            = var.ebs_volume.kms_key_id
        delete_on_termination = var.ebs_volume.delete_on_termination
    }]

    iam_instance_profile = "my-iam-role"

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, DEVOPS PH!" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
}

