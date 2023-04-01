terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#security group: assign security group to jenkins ec2 for traffic on port 22 from your IP & traffic from port 8080
resource "aws_security_group" "jenkins-ssh" {
  name        = "jenkins-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-12345abcdef"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
resource "aws_instance" "jenkins-server" {
  ami                    = "ami-04581fbf744a7d11f"
  instance_type          = "t2.micro"
  key_name               = "your_keypair"
  vpc_security_group_ids = [aws_security_group.jenkins-ssh.id]
  subnet_id              = "subnet-abcdefg12345"
  user_data              = file("jenkins.sh")
}

resource "aws_s3_bucket" "my-jenkins-b-2023" {
  bucket = "my-jenkins-b-2023"
}

resource "aws_s3_bucket_acl" "my-jenkins-b-2023" {
  bucket = aws_s3_bucket.my-jenkins-b-2023.id
  acl    = "private"
}