variable "avability_zone" {
    type = string
    default = "us-east-2"

}

variable "ami" {
    type = string
    default = "ami-0d1b5a8c13042c939"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "public_subnet_cidrs" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    description = "Public Subnet CIDR values"
}

variable "private_subnet_cidrs" {
    type = list(string)
    default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    description = "Public Subnet CIDR values"
}

variable "azs" {
    type = list(string)
    default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}