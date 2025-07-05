# Create AWS Infrastructure with Terraform (Step by Step guidance)

This repository contains Terraform code to provision a comprehensive AWS environment. It demonstrates how to create a custom Virtual Private Cloud (VPC), launch an EC2 instance within it, and set up an S3 bucket. This guide provides a detailed, step-by-step explanation of the entire process.

## Table of Contents

- [Prerequisites](#prerequisites)
- [How to Use](#how-to-use)
- [Detailed Infrastructure Breakdown](#detailed-infrastructure-breakdown)
  - [1. AWS Provider Configuration](#1-aws-provider-configuration)
  - [2. Creating a Custom VPC](#2-creating-a-custom-vpc)
  - [3. Setting up Subnets](#3-setting-up-subnets)
  - [4. Internet Gateway and Routing](#4-internet-gateway-and-routing)
  - [5. Launching an EC2 Instance](#5-launching-an-ec2-instance)
  - [6. Creating an S3 Bucket](#6-creating-an-s3-bucket)
- [Customization (Variables)](#customization-variables)
- [Outputs](#outputs)
- [Destroying the Infrastructure](#destroying-the-infrastructure)

## Prerequisites

Before you begin, ensure you have the following:

1.  **Terraform**: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
2.  **AWS Account**: An active AWS account.
3.  **AWS CLI**: [Install and configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with your access credentials.
4.  **EC2 Key Pair**: An existing EC2 Key Pair in your target AWS region. The name of this key pair is required for SSH access to the EC2 instance.

## How to Use

1.  **Clone the Repository**

    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Initialize Terraform**

    This command prepares your working directory for Terraform.

    ```bash
    terraform init
    ```

3.  **Review the Execution Plan**

    See what resources Terraform will create before making any changes.

    ```bash
    terraform plan
    ```

4.  **Apply the Configuration**

    This command builds the resources on AWS.

    ```bash
    terraform apply
    ```

    Confirm the action by typing `yes` when prompted.

## Detailed Infrastructure Breakdown

### 1. AWS Provider Configuration

This block configures the AWS provider, specifying the region where all the resources will be created. The region is sourced from a variable for easy customization.

```terraform
provider "aws" {
    region = var.avability_zone
}
```

### 2. Creating a Custom VPC

A Virtual Private Cloud (VPC) is a logically isolated section of the AWS Cloud where you can launch AWS resources. We define a VPC with a specific CIDR block, which provides a private network space.

```terraform
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo VPC"
  }
}
```

### 3. Setting up Subnets

Subnets are subdivisions of your VPC. We create both public and private subnets across multiple Availability Zones (AZs) for high availability.

-   **Public Subnets**: These subnets have a route to the internet.
-   **Private Subnets**: These subnets are for resources that shouldn't be directly accessible from the internet.

```terraform
# Public Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  count             = length(var.public_subnet_cidrs)
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  count             = length(var.private_subnet_cidrs)
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}
```

### 4. Internet Gateway and Routing

To allow communication between instances in your VPC and the internet, you need an Internet Gateway and a Route Table.

-   **Internet Gateway (IGW)**: Provides a target in your VPC route tables for internet-routable traffic.
-   **Route Table**: Contains a set of rules, called routes, that determine where network traffic is directed.
-   **Route Table Association**: Connects the route table to our public subnets.

```terraform
# Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Demo VPC ig"
  }
}

# Route Table
resource "aws_route_table" "second_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "2nd Round Table"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.second_rt.id
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}
```

### 5. Launching an EC2 Instance

This is the virtual server. We launch it into one of our public subnets and associate it with a key pair to allow for SSH access.

```terraform
resource "aws_instance" "my_instance" {
    ami           = var.ami
    instance_type = var.instance_type
    key_name      = var.key_name
    subnet_id     = aws_subnet.public_subnet[0].id

    tags = {
        Name = "Demo-instance"
    }
}
```

### 6. Creating an S3 Bucket

Amazon S3 is an object storage service. This code creates a new, globally unique S3 bucket.

```terraform
resource "aws_s3_bucket" "my_bucket" {
    bucket = "terraform-bucket-0007"

    tags = {
        Name = "Demo bucket"
    }
}
```

## Customization (Variables)

You can modify the `variables.tf` file to change the configuration without altering the main code.

| Variable               | Description                                       | Default Value                               |
| ---------------------- | ------------------------------------------------- | ------------------------------------------- |
| `avability_zone`       | The AWS region for resource creation.             | `"us-east-2"`                               |
| `ami`                  | The AMI ID for the EC2 instance.                  | `"ami-0d1b5a8c13042c939"` (Amazon Linux 2) |
| `instance_type`        | The EC2 instance type.                            | `"t2.micro"`                                |
| `public_subnet_cidrs`  | CIDR blocks for public subnets.                   | `["10.0.1.0/24", ...]`                      |
| `private_subnet_cidrs` | CIDR blocks for private subnets.                  | `["10.0.4.0/24", ...]`                      |
| `azs`                  | Availability Zones for subnets.                   | `["us-east-2a", ...]`                       |
| `key_name`             | The name of your EC2 Key Pair for SSH.            | `"terraform-key"`                           |

## Outputs

After deployment, Terraform will display the following outputs:

| Output              | Description                               |
| ------------------- | ----------------------------------------- |
| `instance_public_ip`  | The public IP address of the EC2 instance. |
| `instance_public_dns` | The public DNS name of the EC2 instance.  |

## Destroying the Infrastructure

To remove all the resources created by this Terraform configuration, run the following command:

```bash
terraform destroy
```
