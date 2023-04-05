provider "aws" {
  region = "us-east-1"
}

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

resource "aws_launch_template" "my-tf-launch" {
  name = "my-tf-launch"

  image_id = "ami-04581fbf744a7d11f"

  instance_type = "t2.micro"

  key_name = "keypair_name"

  vpc_security_group_ids = [aws_security_group.tf-asg-sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tf-asg-proj"
    }
  }

  user_data = file("apache.sh")
}

resource "aws_s3_bucket" "my-tf-asg-2023" {
  bucket = "my-tf-asg-2023"
}

resource "aws_s3_bucket_acl" "my-tf-asg-2023" {
  bucket = aws_s3_bucket.my-tf-asg-2023.id
  acl    = "private"
}

resource "aws_autoscaling_group" "my-tf-asg" {
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  #vpc_zone_identifier = [var.subnet-public1-us-east-1a.id, var.subnet-public2-us-east-1b.id]

  launch_template {
    id = aws_launch_template.my-tf-launch.id
  }

  tag {
    key                 = "Name"
    value               = "my-tf-asg"
    propagate_at_launch = true
  }
}