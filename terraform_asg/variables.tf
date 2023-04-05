variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "default_vpc" {
  type    = string
  default = "vpc-123456789"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "subnet-private1-us-east-1a" = 1
    "subnet-private2-us-east-1b" = 2
  }
}

variable "public_subnets" {
  default = {
    "subnet-public1-us-east-1a" = 1
    "subnet-public2-us-east-1b" = 2
  }
}