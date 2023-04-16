variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2"
  type    = string
  default = "ami-069aabeee6f53e7bf"
}

variable "vpc_name" {
  description = "Name for Custom VPC"
  type    = string
  default = "tt-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "us-aze1a" {
  description = "First AZ for public and private subnets"
  type    = string
  default = "us-east-1a"
}

variable "us-aze1b" {
  description = "Second AZ for public and private subnets"
  type    = string
  default = "us-east-1b"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}