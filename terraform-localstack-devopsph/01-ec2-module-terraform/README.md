## Tutorial: Using the Terraform EC2 Community Module

This tutorial will guide you through using the Terraform EC2 community module, explaining its importance, setup, customization, and differences compared to creating resources from scratch.

### Importance of Using Community Modules

As you manage your infrastructure with Terraform, configurations can become complex. Using community modules helps to solve several problems that arise with complex configurations:

*   **Organization:** Modules make it easier to navigate, understand, and update configurations by grouping related parts together.
*   **Encapsulation:** Modules encapsulate configuration into distinct components, preventing unintended consequences and reducing errors.
*   **Reusability:**  Modules save time and reduce errors by reusing configurations created by you, your team, or other Terraform practitioners. Sharing modules also allows others to benefit from your work.
*  **Consistency and Best Practices**: Modules help ensure consistency across your configurations, applying best practices in all cases.
*   **Self-Service**: Modules make configurations easier for other teams to use, with the HCP Terraform registry allowing teams to find and reuse published modules. No-code ready modules can also be created, letting teams without Terraform expertise provision their own infrastructure.

In essence, using community modules, like the EC2 module, allows you to leverage pre-built, well-maintained configurations, saving time and improving the reliability of your infrastructure.

### Step-by-Step Setup

This section details how to integrate the Terraform EC2 community module into your workflow.

#### Prerequisites

*   **Terraform:** Ensure you have Terraform installed.
*   **AWS Account:** You need an AWS account to create resources.
*   **Basic Terraform Knowledge:** Familiarity with Terraform concepts, such as providers, resources, and modules, is helpful.

#### Step 1: Create a Custom Module

Start by creating your own custom module to manage your EC2 instances. This approach allows you to add your own logic and group related resources.

1.  Create a new directory, for example, `ec2-module`.
2.  Inside the `ec2-module` directory, create the following files:
    *   `main.tf`: For resource definitions.
    *   `variables.tf`: For defining input variables.
    *   `outputs.tf`: For defining output values.

#### Step 2: Integrate the Community Module in main.tf

In your `main.tf` file, you'll integrate the community EC2 module. An example is shown below, which uses version `2.17` of the `terraform-aws-modules/ec2-instance/aws` module.

```terraform
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name          = var.instance_name
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  subnet_id     = var.subnet_id

  root_block_device = [
    {
      volume_size = var.root_volume_size
      volume_type = var.root_volume_type
    }
  ]

  tags = merge(var.default_tags, var.tags)
}
```

**Explanation:**

*   **`module "ec2_instance"`:** Declares a module block, which calls the community module.
*   **`source`:**  Specifies the location of the module, in this case, the Terraform Registry.
*   **`version`:**  Specifies the version of the module to use.
*   **`name`:** A tag that is applied to the resource.
*   **`ami`**, **`instance_type`**, **`vpc_security_group_ids`**, **`subnet_id`**: These are variables that should be defined in `variables.tf`. They specify the instance configuration.
*   **`root_block_device`:** This is a list of maps, specifying details about the root block device.
*    **`tags`:** A map of tags applied to the instance, merged with `default_tags`.

#### Step 3: Define Variables

In your `variables.tf` file, define all the input variables used in `main.tf`:

```terraform
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default = "my-ec2-instance"
}

variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t2.micro"
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_id" {
  description = "The subnet ID for the instance"
  type        = string
}

variable "root_volume_size" {
    description = "The size of the root volume"
    type        = number
    default = 20
}
variable "root_volume_type" {
    description = "The type of the root volume"
    type        = string
    default = "gp3"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}
```

#### Step 4: Define Outputs
In your `outputs.tf` file, define the output variables that expose information from the community module.

```terraform
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value = module.ec2_instance.arn
}
```
*   **`value = module.ec2_instance.id`**: This uses the module syntax to reference the output `id` from the `ec2_instance` module, and selects the first element of the list (index 0).

#### Step 5: Add Additional Logic (Optional)

You can add other resources and logic to your custom module, such as:

*   **Elastic IP:** Create an Elastic IP and associate it with the instance. Use the instance ID from the community module to link the resources.

```terraform
resource "aws_eip" "eip" {
  count = var.create_eip ? 1 : 0

  domain = "vpc"
}

resource "aws_eip_association" "eip_association" {
  count = var.create_eip ? 1 : 0

  instance_id   = module.ec2_instance.id
  allocation_id = aws_eip.eip.id
}
```
*  Add `create_eip` as a variable in `variables.tf`.
*  Use conditional `count` to only create this resource when `var.create_eip` is `true`.

#### Step 6: Using the Custom Module
To use the custom module, create a new `main.tf` in another directory, and call the module like this:

```terraform
module "my_ec2" {
  source = "./ec2-module"

  ami_id              = "ami-xxxxxxxxxxxxx" # Replace with a valid AMI ID
  security_group_ids  = ["sg-xxxxxxxxxxxxx"]  # Replace with valid Security Group IDs
  subnet_id           = "subnet-xxxxxxxxxxxxx" # Replace with a valid Subnet ID
  instance_name = "my-ec2-instance"
  tags = {
    Environment = "dev"
    Project = "Test"
  }
  create_eip = true # Creates an elastic IP if true
}

output "ec2_instance_id" {
  value = module.my_ec2.instance_id
}

output "ec2_instance_arn" {
  value = module.my_ec2.instance_arn
}

```

#### Step 7: Initialize and Apply
After creating the files, run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

### What Can Be Changed
The beauty of using modules is that many things can be easily changed. The input variables that you defined in the `variables.tf` file can be changed in the module block. The root block device configuration, instance type, ami, tags, security groups, etc. can be easily adjusted by changing variables in the module definition, making customization easy.

### Differences from Scratch

*   **Community modules** offer a more structured, well-tested, and easier to maintain approach. The community module for EC2, for example, includes dynamic blocks that allow you to set properties that you would need to define yourself if you wrote the code from scratch.
*   **Modules** also make it easier to reuse configurations and add your own custom logic. In comparison, building from scratch might cause an increased amount of duplication of similar blocks of configuration.
*   You gain additional functionality and capabilities.  You can use modules to organize your code as you see fit, and then pass variables directly into the community module.
*   **Community modules** can be updated with new features or security patches.  If you create from scratch, you are responsible for maintaining the code. If you use a community module, others will contribute to it, making it easier to maintain the configuration.

### Important Considerations

*   **Module Versioning:** Always specify a version when using community modules to avoid unexpected changes.
*   **Documentation:** Refer to the module's documentation for available options and best practices.
*   **Over-Abstraction**: Avoid over-abstraction of your modules. This can lead to issues with tracking down where issues are coming from.
*   **Provider Configuration:**  When using modules with localstack, make sure you configure your provider correctly. LocalStack supports Terraform via the AWS provider through custom service endpoints that should be configured using either a wrapper script, or manual configuration.
* **CDKTF**:  Cloud Development Kit for Terraform (CDKTF) can also be used with localstack and supports all the providers and modules available in the terraform registry. You can use general purpose programming languages like Python or Typescript.

### Conclusion

Using Terraform community modules like the EC2 module simplifies your infrastructure management by providing pre-built, reliable, and customizable components. This tutorial has shown how to integrate community modules into a custom module to organize your resources, manage dependencies, and easily maintain your infrastructure.  By following these best practices, you can streamline your Terraform projects and enhance your overall infrastructure management strategy.

# SUCCESS SAMPLE

![Terraform Plan Success](TERRAFORM_PLAN_SUCCESS.png)