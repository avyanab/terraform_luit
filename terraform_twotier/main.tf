provider "aws" {
  region = var.aws_region
}

#create a custom VPC 
resource "aws_vpc" "tt-vpc" {
  cidr_block = "10.10.0.0/16"
}

#2 public subnets for web server tier
resource "aws_subnet" "tt-pubsubnet-1" {
  vpc_id     = aws_vpc.tt-vpc.id
  cidr_block = "10.10.1.0/24"
}

resource "aws_subnet" "tt-pubsubnet-2" {
  vpc_id     = aws_vpc.tt-vpc.id
  cidr_block = "10.10.2.0/24"
}

#2 private subnets for RDS tier
resource "aws_subnet" "tt-privsubnet1" {
  vpc_id     = aws_vpc.tt-vpc.id
  cidr_block = "10.10.3.0/24"
}

resource "aws_subnet" "tt-privsubnet2" {
  vpc_id     = aws_vpc.tt-vpc.id
  cidr_block = "10.10.4.0/24"
}

#security groups
resource "aws_security_group" "tf-tt-sg" {
  name   = "tf-tt-sg"
  vpc_id = aws_vpc.tt-vpc.id
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

#internet gateway
resource "aws_internet_gateway" "tt-igw" {
  vpc_id = aws_vpc.tt-vpc.id

  tags = {
    Name = "tt-vpc"
  }
}

#route tables
resource "aws_route_table" "tt-rt" {
  vpc_id = aws_vpc.tt-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = aws_internet_gateway.tt-igw.id
  }

  tags = {
    Name = "my-tt-rt"
  }
}

#EC2 instance with NGINX server
module "web_server" {
  source = "./server"
  region = var.aws_region
}

#RDS MySQL Instance
resource "aws_db_instance" "my-tt-db" {
  allocated_storage    = 20
  db_name              = "my-tt-db"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "--"
  password             = "--"
  skip_final_snapshot  = true
}