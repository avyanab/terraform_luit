variable "aws_region" {
  type    = string
  default = "us-east-1"
}
#add default VPC ID
variable "default_vpc" {
  type    = string
  default = "vpc-123456"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
#add subnet IDs for public and private subnets in VPC
variable "subnet-private1-us-east-1a" {
  default = "subnet-123456"
}

variable "subnet-private2-us-east-1b" {
  default = "subnet-123456"
}

variable "subnet-public1-us-east-1a" {
  default = "subnet-123456"
}

variable "subnet-public2-us-east-1b" {
  default = "subnet-123456"
}