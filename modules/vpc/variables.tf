
variable "vpc_name" {}

variable "region" {}

variable "vpc_cidr_block" {
    default         = "20.0.0.0/16"
}

variable "azs" {
    default = {
        "us-west-2" = ["us-west-2a","us-west-2b","us-west-2c"]
    }
}

variable "private_subnet_ec2" {
  description       = "A list of private subnets inside the VPC."
  default           = ["20.0.0.0/24","20.0.1.0/24","20.0.2.0/24"]
}

variable "private_subnet_rds" {
  description       = "A list of private subnets inside the VPC."
  default           = ["20.0.10.0/24","20.0.11.0/24","20.0.12.0/24"]
}

variable "private_subnet_alb" {
  description       = "A list of private subnets inside the VPC."
  default           = ["20.0.20.0/24","20.0.21.0/24","20.0.22.0/24"]
}
