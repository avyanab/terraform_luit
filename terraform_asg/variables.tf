variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-04581fbf744a7d11f"
}

variable "default_vpc" {
  type    = string
  default = "vpc-04f12000e3bbb67f3"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet-private1-us-east-1a" {
  default = "subnet-0ed9298622589362b"
}

variable "subnet-private2-us-east-1b" {
  default = "subnet-0d2208d14e0cc378f"
}

variable "subnet-public1-us-east-1a" {
  default = "subnet-0bd8cc27db41bea3b"
}

variable "subnet-public2-us-east-1b" {
  default = "subnet-0d09fcb733be8a23a"
}