# TERRAFORM MODULES


**Definition**

- A collection of `.tf` or `.tf.json` files grouped together to create reusable infrastructure components.

**Purpose**

1. **Specialization**: Enables infrastructure specialists to create modular, reusable configurations.
2. **Focus**: Allows application developers to focus on code without needing deep knowledge of infrastructure setup.
### Types of Modules

1. **Root Module**
    
    - The primary module Terraform loads and executes.
    - Includes all `.tf` files in the current working directory.
2. **Child Module**
    
    - Reusable modules called by the root module or other child modules.
    - Stored in separate directories or fetched from external sources.

---

### Module Sources

Modules can be sourced from:

1. **Local Path**:
    
    - Reference a directory in the same repository.
    - Example:
        
        ```hcl
        module "network" {
          source = "./modules/network"
        }
        ```
        
2. **Terraform Registry**:
    
    - Use modules published in the Terraform public registry.
    - Example:
        
        ```hcl
        module "vpc" {
          source  = "terraform-aws-modules/vpc/aws"
          version = "3.5.0"
        }
        ```
        
3. **Git Repository**:
    
    - Fetch from a GitHub, GitLab, or other Git repository.
    - Example:
        
        ```hcl
        module "security_group" {
          source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.0.0"
        }
        ```
        
4. **HTTP URL**:
    
    - Download an archive from a remote URL.
    - Example:
        
        ```hcl
        module "app" {
          source = "https://example.com/modules/app-module.zip"
        }
        ```
        
5. **Private Registry**:
    
    - Use a module hosted in an organization’s private Terraform registry.
6. **S3 Bucket**:
    
    - Source modules stored in an AWS S3 bucket.
    - Example:
        
        ```hcl
        module "web" {
          source = "s3::https://s3.amazonaws.com/my-bucket/modules/web-app.zip"
        }
        ```
        
### What Makes a Good Module? **USEFUL**

A **useful module** is designed with practicality and adaptability in mind, ensuring it meets the needs of diverse use cases while being easy to integrate and maintain. Here are the key traits that make a module **useful**:
### 1. **Abstraction**

A Terraform module abstracts away complex resource configurations, allowing users to focus on inputs and outputs without worrying about the underlying details.

**Example:** A module to create an AWS EC2 instance:

```hcl
# ec2-instance/main.tf
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  tags          = var.tags
}

# Inputs and outputs make it reusable:
variable "ami" {}
variable "instance_type" { default = "t2.micro" }
variable "tags" { default = {} }

output "instance_id" {
  value = aws_instance.this.id
}
```

---

### 2. **Groups Resources in a Logical Fashion**

Modules group related resources that serve a common purpose, like networking, databases, or application infrastructure.

**Example:** A VPC module with subnets, route tables, and an internet gateway:

```hcl
# vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = var.tags
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}

# Logical grouping for the entire VPC setup
```

---

### 3. **Exposes Input Variables to Allow Customization + Composition**

Input variables make modules flexible and allow users to pass custom values.

**Example:** Expose inputs for CIDR blocks and availability zones:

```hcl
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  default     = "10.0.1.0/24"
}

variable "az" {
  description = "The availability zone for the subnet"
  default     = "us-east-1a"
}
```

---

### 4. **Provides Useful Defaults**

By setting defaults, the module becomes easy to use for common cases without requiring extensive configuration.

**Example:**

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro" # Default for a free-tier instance
}

variable "tags" {
  description = "Tags to apply to all resources"
  default     = {
    Environment = "dev"
    Owner       = "default"
  }
}
```

---

### 5. **Returns Outputs to Make Further Integration Possible**

Modules return key outputs so users can reference them in dependent modules or configurations.

**Example:** Output VPC and Subnet IDs from the VPC module:

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}
```

**Usage:**

```hcl
module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = "10.0.0.0/16"
  private_subnet_cidr  = "10.0.1.0/24"
  az                   = "us-east-1a"
}

# Use the module's output
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnet_id
}
```
