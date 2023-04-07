provider "aws" {
  region = var.aws_region
}

#create security groups for instances launched in default vpc
resource "aws_security_group" "tf-asg-sg" {
  name        = "tf-asg-sg"
  description = "Allow inbound traffic from internet"
  vpc_id      = var.default_vpc
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

#create ec2 instance launch template for auto scaling group
resource "aws_launch_template" "my-tf-launch" {
  name = "my-tf-launch"

  image_id = var.ami_id

  instance_type = var.instance_type

  key_name = "keypair_name"

  vpc_security_group_ids = [aws_security_group.tf-asg-sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tf-asg-proj"
    }
  }
  user_data = filebase64("apache.sh")
}

#auto scaling group to launch minimum of 2 instances and maximum of 5 instances
resource "aws_autoscaling_group" "my-tf-asg" {
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  vpc_zone_identifier = [var.subnet-public1-us-east-1a, var.subnet-public2-us-east-1b]

  launch_template {
    id = aws_launch_template.my-tf-launch.id
  }

  tag {
    key                 = "Name"
    value               = "my-tf-asg"
    propagate_at_launch = true
  }
}

#create an s3 bucket to be used as remote backend
resource "aws_s3_bucket" "my-tf-asg-2023" {
  bucket        = "my-tf-asg-2023"
  force_destroy = true #this will help to destroy an s3 bucket that is not empty 
}

#enable versioning to keep record of any modifications made to s3 bucket files
resource "aws_s3_bucket_versioning" "my-tf-asg-2023" {
  bucket = aws_s3_bucket.my-tf-asg-2023.id
  versioning_configuration {
    status = "Enabled"
  }
}

#s3 bucket access control list will be private
resource "aws_s3_bucket_acl" "my-tf-asg-2023" {
  bucket = aws_s3_bucket.my-tf-asg-2023.id
  acl    = "private"
}

#block s3 bucket objects from public 
resource "aws_s3_bucket_public_access_block" "my-tf-asg-2023" {
  bucket                  = aws_s3_bucket.my-tf-asg-2023.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#create dynamodb table for file-locking of s3 bucket backend
resource "aws_dynamodb_table" "my-tf-dynamodb-2023" {
  name           = "my-tf-dynamodb-2023"
  hash_key       = "LockID" #value "LockID" is required and should remain unchanged
  billing_mode   = "PROVISIONED" 
  read_capacity  = 10 #free-tier eligible
  write_capacity = 10 #free-tier eligible

  attribute {
    name = "LockID" #name "LockID" is required and should remain unchanged
    type = "S"
  }
}