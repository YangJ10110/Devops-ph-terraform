# Infrastructure-as-Code (IaC) using Terraform: A Modularized Approach

This project demonstrates the implementation of a highly organized and modularized Terraform configuration for deploying a web application infrastructure on AWS Localstack. The infrastructure includes compute resources (EC2 instances), networking (security groups, load balancers, and Route 53 DNS), and storage (S3 buckets). This document provides an in-depth explanation of how Terraform's features and best practices were utilized to achieve the desired modular design and functionality.

---

## Key Features of the Configuration

1. **Modular Design**:
   - The project is structured into logical modules (e.g., compute, networking, storage, DNS) to promote reusability, manageability, and scalability.
   - Each module is self-contained, handling a specific component of the infrastructure.

2. **Terraform Features Used**:
   - **Expressions and Operators**: Used for dynamic logic (e.g., conditional creation of DNS records).
   - **Variables and Outputs**: Simplify configuration by allowing customization and exporting key data points.
   - **Local Values**: Consolidate reusable expressions and improve readability.
   - **Modules**: Encapsulate resources for reuse across multiple configurations.
   - **Data Sources**: Fetch existing AWS resources dynamically, such as VPC and Route 53 zones.

3. **AWS Localstack Integration**:
   - Configured to use Localstack endpoints for development and testing, bypassing real AWS services.

4. **Security Best Practices**:
   - Separate security groups for ALB and EC2 instances.
   - HTTP access restricted to port `80` and scoped to all IPs (for simplicity in development).

---

## Directory Structure

```plaintext
├── web-app/             # Main entry point for Terraform configuration
│   └── main.tf          # References individual modules
├── web-app-modules/     # Contains reusable modules
│   ├── compute.tf       # EC2 instances and user data
│   ├── dns.tf           # Route 53 configurations
│   ├── networking.tf    # Security groups and load balancers
│   ├── storage.tf       # S3 bucket configurations
│   ├── variables.tf     # Input variables for modules
│   ├── output.tf        # Outputs for each module
└── README.md            # Documentation
```

---

## Explanation of Components

### 1. **Main Terraform Configuration (`web-app/main.tf`)**

The `main.tf` file is the entry point, where the infrastructure is assembled by referencing modules. Each module encapsulates a specific functionality:

```hcl
module "web-server-1" {
    source = "../web-app-modules"

    bucket_prefix    = "web-server-1-data"
    domain           = "devopsPH.com"
    app_name         = "web-server-1"
    environment_name = "production"
    instance_type    = "t2.micro"
    create_dns_zone  = true
}
```

Key Highlights:
- Input variables are passed to customize each instance.
- Multiple instances (e.g., `web-server-1`, `web-server-2`) can be deployed using the same module.

---

### 2. **Compute Module (`web-app-modules/compute.tf`)**

Defines EC2 instances and their configuration:

```hcl
resource "aws_instance" "instance_1" {
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instances.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "DEVOPS PH # 1" > index.html
    nohup busybox httpd -f -p 80 &
  EOF
}
```

Key Highlights:
- **User Data**: Configures a simple web server for demonstration.
- **Security Groups**: EC2 instances are assigned security groups dynamically.

---

### 3. **Networking Module (`web-app-modules/networking.tf`)**

Handles security groups, load balancers (ALB), and associated rules:

```hcl
resource "aws_security_group" "alb" {
  name = "alb-localstack-sg"
}

resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
}
```

Key Highlights:
- Security groups are dynamically assigned to ALB and EC2 instances.
- Load balancer forwards traffic to EC2 target groups.

---

### 4. **Storage Module (`web-app-modules/storage.tf`)**

Configures S3 buckets for application data:

```hcl
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

Key Highlights:
- Server-side encryption ensures data security.
- Buckets are versioned for reliability.

---

### 5. **DNS Module (`web-app-modules/dns.tf`)**

Configures Route 53 for domain management:

```hcl
resource "aws_route53_zone" "primary" {
  count = var.create_dns_zone ? 1 : 0
  name  = var.domain
}

resource "aws_route53_record" "root" {
  zone_id = local.dns_zone_id
  name    = "${local.subdomain}${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
```

Key Highlights:
- Conditional logic determines whether to create a new DNS zone or use an existing one.
- DNS records are dynamically assigned based on the environment.

---

### 6. **Variables and Outputs (`web-app-modules/variables.tf` and `output.tf`)**

#### Variables:
- Centralize configurable options such as `instance_type`, `region`, and `domain`.
- Default values provide sensible fallbacks while allowing overrides.

Example:
```hcl
variable "region" {
  description = "Default region for provider"
  type        = string
  default     = "us-east-1"
}
```

#### Outputs:
- Export useful information such as public IPs and bucket names for external consumption.

Example:
```hcl
output "instance_1_ip_addr" {
  value = aws_instance.instance_1.public_ip
}
```

---

## Terraform Features and Best Practices

1. **Modules**:
   - Encapsulate resources and logic, making configurations reusable.
   - Reduce redundancy by parameterizing variables.

2. **Expressions and Conditional Logic**:
   - Dynamic resource creation using `count` and `for_each`.
   - Conditional assignments like DNS zone creation.

3. **Data Sources**:
   - Dynamically fetch existing AWS resources (e.g., VPCs, subnets).

4. **Local Values**:
   - Simplify expressions and avoid duplication.

5. **Outputs**:
   - Export critical information for other modules or external use.

---

## How to Run

1. **Initialize Terraform**:
   ```bash
   tflocal init
   ```

2. **Validate Configuration**:
   ```bash
   tflocal validate
   ```

3. **Plan Deployment**:
   ```bash
   tflocal plan
   ```

4. **Apply Configuration**:
   ```bash
   tflocal apply
   ```

---

## Conclusion

This project highlights the power of Terraform's modular design and feature set, enabling scalable and reusable infrastructure management. By leveraging modules, variables, and dynamic logic, the configuration ensures flexibility while maintaining simplicity and clarity for both development and production environments.

