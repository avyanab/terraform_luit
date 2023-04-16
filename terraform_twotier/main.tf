provider "aws" {
  region = var.aws_region
}

#create a custom VPC
resource "aws_vpc" "tt-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "project"
    Terraform   = "true"
  }

  enable_dns_hostnames = true
}

#create internet gateway to attach to custom VPC
resource "aws_internet_gateway" "tt-igw" {
  vpc_id = aws_vpc.tt-vpc.id

  tags = {
    Name = "tt-igw"
  }
}

#Deploy two public subnets for web server tier
resource "aws_subnet" "tt-pubsubnet-1" {
  vpc_id                  = aws_vpc.tt-vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = var.us-aze1a
  map_public_ip_on_launch = true

  tags = {
    Name = "tt-pubsubnet-1"
  }
}

resource "aws_subnet" "tt-pubsubnet-2" {
  vpc_id                  = aws_vpc.tt-vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = var.us-aze1b
  map_public_ip_on_launch = true

  tags = {
    Name = "tt-pubsubnet-2"
  }
}

#Deploy two private subnets for RDS tier
resource "aws_subnet" "tt-privsubnet1" {
  vpc_id            = aws_vpc.tt-vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = var.us-aze1a

  tags = {
    Name = "tt-privsubnet1"
  }
}

resource "aws_subnet" "tt-privsubnet2" {
  vpc_id            = aws_vpc.tt-vpc.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = var.us-aze1b

  tags = {
    Name = "tt-privsubnet2"
  }
}

#create public route table with route for internet gateway 
resource "aws_route_table" "public-tt-rt" {
  vpc_id = aws_vpc.tt-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tt-igw.id
  }

  tags = {
    Name = "public-tt-rt"
  }
}

#create private route table with route for NAT gateway
resource "aws_route_table" "private-tt-rt" {
  vpc_id = aws_vpc.tt-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tt-nat-gw.id
  }

  tags = {
    Name = "private-tt-rt"
  }
}

#public route table with public subnet associations
resource "aws_route_table_association" "publicsub1" {
  route_table_id = aws_route_table.public-tt-rt.id
  subnet_id      = aws_subnet.tt-pubsubnet-1.id
}

resource "aws_route_table_association" "publicsub2" {
  route_table_id = aws_route_table.public-tt-rt.id
  subnet_id      = aws_subnet.tt-pubsubnet-2.id
}

#private route table with private subnet associations
resource "aws_route_table_association" "privatesub1" {
  route_table_id = aws_route_table.private-tt-rt.id
  subnet_id      = aws_subnet.tt-privsubnet1.id
}

resource "aws_route_table_association" "privatesub2" {
  route_table_id = aws_route_table.private-tt-rt.id
  subnet_id      = aws_subnet.tt-privsubnet2.id
}

#create an elastic IP to assign to NAT Gateway
resource "aws_eip" "tt-nat-eip" {
  vpc        = true #confirms if the EIP is in a VPC or not
  depends_on = [aws_internet_gateway.tt-igw]
  tags = {
    Name = "tt-nat-eip"
  }
}

#create a NAT Gateway to give private subnets access to external resources
resource "aws_nat_gateway" "tt-nat-gw" {
  depends_on    = [aws_eip.tt-nat-eip]
  allocation_id = aws_eip.tt-nat-eip.id
  subnet_id     = aws_subnet.tt-pubsubnet-1.id
  tags = {
    Name = "tt-nat-gw"
  }
}

#security groups allowing inbound traffic from internet
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

#create EC2 instance launch template for auto scaling group
resource "aws_launch_template" "tf-tt-launch" {
  name                   = "tf-tt-launch"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = "luitproject"
  vpc_security_group_ids = [aws_security_group.tf-tt-sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "NGINX-app"
    }
  }
  user_data = filebase64("nginx.sh")
}

#auto scaling group to launch minimum of 2 instances and maximum of 3 instances
resource "aws_autoscaling_group" "tf-tt-asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [var.us-aze1a, var.us-aze1b]

  launch_template {
    id = aws_launch_template.tf-tt-launch.id
  }

  tag {
    key                 = "Name"
    value               = "tf-tt-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "mysql-sg" {
  name   = "mysql-sg"
  vpc_id = aws_vpc.tt-vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
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

#create RDS MySQL Instance
resource "aws_db_instance" "dbinstance" {
  allocated_storage      = 20
  db_name                = "dbinstance"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  
  #credentials will be added as sensitive variables in Terraform Cloud
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.mysql-sg.id]
  db_subnet_group_name   = "db-subnet-grp"
  skip_final_snapshot    = true
}

#subnet group for RDS instance
resource "aws_db_subnet_group" "db-subnet-grp" {
  name       = "db-subnet-grp"
  subnet_ids = [aws_subnet.tt-privsubnet1.id, aws_subnet.tt-privsubnet2.id]

  tags = {
    Name = "My DB private subnet group"
  }
}