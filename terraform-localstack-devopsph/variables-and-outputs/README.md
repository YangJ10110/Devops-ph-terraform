
#### Input Variable
- this is for defining parameters that can be passed into terraform module/configuration

```hcl
variable "instance_type" {
	description = "ec2 instance type"
	type = string
	default = "t2.micro"
}
```

- in this example "instance_type" is a variable that can be re-used in other parts of the terraform

#### Local Variables
- this is for defining constants/computed values within terraform
- centralizing values that are used multiple times 

```hcl
locals {
	service_name = "My Service"
	owner = "Localstack"
}
```

#### Output Variables
- Output variables are used to **display values** or make them **available for other modules to consume**.
- expose specific information about resources or configurations that were created
- helpful for:
	1. debugging
	2. sharing data between module
	3. providing critical information to end users

```hcl
output "instance_ip_addr" {
 value = aws_instance.instance.public_ip
}
```

- This code outputs the **public IP address** of an AWS EC2 instance defined elsewhere in the Terraform configuration.

#### Value Types

**Primitive Types:** Used for simple single values.

- **String:** Textual data.
- **Number:** Numeric data.
- **Bool:** Boolean true/false values.

**Complex Types:** Used for collections or structured data.

- **list:** Ordered collection of values.
- **set:** Unordered collection of unique values.
- **map:** Key-value pairs.
- **object:** Structured collection with named attributes.
- **tuple:** Fixed-length ordered collection of values with different types.

**Validation:** Ensures correctness by automatic type checking and enforcing custom conditions.

```hcl
variable "region" {
  type        = string
  description = "AWS region"
  validation {
    condition     = contains(["us-east-1", "us-west-1"], var.region)
    error_message = "Region must be us-east-1 or us-west-1."
  }
}
```

#### Sensitive Data

Marking variables
`sensitive_value = (sensitive)`
- using the output variables using services like secret manager
- can be extracted with tfvars 

#### Precedence of Variables

Lowest -> Highest
Here’s a shorter version with examples:

1. **Manual Entry:** Provide values interactively during `terraform apply`.
    
    ```hcl
    variable "instance_type" {
      description = "EC2 instance type"
    }
    ```
    
    When run:
    
    ```bash
    terraform apply
    var.instance_type
      Enter a value: t3.micro
    ```
    
2. **Default Value (Declaration Block):** Use a predefined fallback value if none is provided.
    
    ```hcl
    variable "region" {
      default = "us-east-1"
    }
    ```
    
3. **TF_VAR_<<'NAME'>> Environment Variables:** Set variables via environment variables.
    
    ```bash
    export TF_VAR_region="us-west-2"
    terraform apply
    ```
    
4. **`***.auto.tfvars` File:** Store variables in a file automatically loaded by Terraform.
    
    ```hcl
    # variables.auto.tfvars
    region = "ap-southeast-1"
    ```
    
5. **Command Line (`-var` or `-var-file`):** Override variables directly via CLI.
    
    ```bash
    terraform apply -var="region=eu-central-1"
    terraform apply -var-file="variables.tfvars"
    ```



