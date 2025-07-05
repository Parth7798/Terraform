# Create an AWS EC2 Instance with a new VPC using Terraform

This Terraform configuration provisions a complete AWS environment including a new VPC, public and private subnets, an Internet Gateway, and then launches an EC2 instance within one of the public subnets. It also creates an S3 bucket as part of the infrastructure.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **Terraform**: [Download and install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
2.  **AWS Account**: You will need an active AWS account.
3.  **AWS CLI**: [Install and configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with your credentials.
4.  **EC2 Key Pair**: You must have an existing EC2 Key Pair in the target AWS region. You will need to provide the name of this key pair in the `variables.tf` file or as an input variable.

## How to Use

1.  **Clone the Repository (or download the files)**

    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Initialize Terraform**

    This command initializes the working directory, downloading the necessary provider plugins.

    ```bash
    terraform init
    ```

3.  **Review the Plan**

    This command shows you what resources Terraform will create, modify, or destroy.

    ```bash
    terraform plan
    ```

4.  **Apply the Configuration**

    This command applies the changes and builds the infrastructure on AWS.

    ```bash
    terraform apply
    ```

    You will be prompted to confirm the action. Type `yes` to proceed.

5.  **Destroy the Infrastructure**

    When you no longer need the resources, you can destroy them to avoid incurring further charges.

    ```bash
    terraform destroy
    ```

## Configuration Details

### Input Variables (`variables.tf`)

You can customize the deployment by modifying the `variables.tf` file or by passing variables via the command line (`-var="key_name=my-key"`).

| Variable               | Description                                       | Default Value                               |
| ---------------------- | ------------------------------------------------- | ------------------------------------------- |
| `avability_zone`       | The AWS region where resources will be created.   | `"us-east-2"`                               |
| `ami`                  | The Amazon Machine Image (AMI) ID for the EC2 instance. | `"ami-0d1b5a8c13042c939"` (Amazon Linux 2) |
| `instance_type`        | The type of EC2 instance to launch.               | `"t2.micro"`                                |
| `public_subnet_cidrs`  | A list of CIDR blocks for the public subnets.     | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` |
| `private_subnet_cidrs` | A list of CIDR blocks for the private subnets.    | `["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]` |
| `azs`                  | A list of Availability Zones for the subnets.     | `["us-east-2a", "us-east-2b", "us-east-2c"]`  |
| `key_name`             | The name of your EC2 Key Pair for SSH access.     | `"terraform-key"`                           |

### Outputs (`outputs.tf`)

After a successful deployment, Terraform will output the following information:

| Output              | Description                               |
| ------------------- | ----------------------------------------- |
| `instance_public_ip`  | The public IP address of the EC2 instance. |
| `instance_public_dns` | The public DNS name of the EC2 instance.  |
