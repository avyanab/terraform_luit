provider "aws" {
  region = var.aws_region
}

#create a custom VPC 
resource "aws_vpc" "tt-vpc" {
  cidr_block = 
}

#2 public subnets for web server tier
resource "aws_subnet" "tt-pubsubnet-1" {  
   vpc_id =  aws_vpc.tt-vpc.id
   cidr_block = 
 }

resource "aws_subnet" "tt-pubsubnet-2" {  
   vpc_id =  aws_vpc.tt-vpc.id
   cidr_block = 
 }

#2 private subnets for RDS tier
resource "aws_subnet" "tt-privsubnet1" {  
   vpc_id =  aws_vpc.tt-vpc.id
   cidr_block = 
 }

resource "aws_subnet" "tt-privsubnet2" {  
   vpc_id =  aws_vpc.tt-vpc.id
   cidr_block = 
 }

#security groups
resource "aws_security_group" "tf-tt-sg" {
  name        = "tf-tt-sg"
  vpc_id      = aws_vpc.tt-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#route tables
resource "aws_route_table" "tt-rt" {
  vpc_id = aws_vpc.tt-vpc.id

  route {
    cidr_block = 
    gateway_id = 
  }

  route {
    ipv6_cidr_block        = 
    egress_only_gateway_id = 
  }

  tags = {
    Name =
  }
}

#EC2 instance with NGINX server
resource "aws_instance" "nginx-webserver" {
  ami = var.ami_id
  instance_type = var.instance_type
}

#RDS MySQL Instance 