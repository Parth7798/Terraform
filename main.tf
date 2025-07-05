provider "aws"{
    region = var.avability_zone


}

resource "aws_instance" "my_instance"{
    ami = var.ami
    instance_type = var.instance_type

    tags = {
        Name = "Demo-instance"
    }

    
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "terraform-bucket-0007"

    tags = {
        Name = "Demo bucket"
    }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo VPC"
  }

}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count = length(var.public_subnet_cidrs)
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count = length(var.private_subnet_cidrs)
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Demo VPC ig"
  }
}

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

resource "aws_route_table_association" "public_subnet_asso" {
  count = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.second_rt.id
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
}