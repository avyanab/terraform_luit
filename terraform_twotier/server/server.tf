# Launch EC2 instance --child module 
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon-2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.tf-tt-sg.id]
  user_data              = filebase64("./server/nginx.sh")
}

data "aws_ami" "amazon-2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}