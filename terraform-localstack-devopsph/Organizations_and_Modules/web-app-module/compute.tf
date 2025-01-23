resource "aws_instance" "instance_1" {
    ami = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.instances.name]

    user_data = <<-EOF
        #!/bin/bash
        echo "DEVOPS PH # 1" > index.html
        nohup busybox httpd -f -p 80 &
    EOF

    
}

resource "aws_instance" "instance_2" {
    ami = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.instances.name]

    user_data = <<-EOF
        #!/bin/bash
        echo "DEVOPS PH # 2" > index.html
        nohup busybox httpd -f -p 80 &
    EOF

    
}


