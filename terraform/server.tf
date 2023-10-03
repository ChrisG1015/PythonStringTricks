provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Example security group"
  
  // Allow incoming SSH (port 22) traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your desired IP range
  }
}

resource "aws_key_pair" "example_keypair" {
  key_name   = "example-keypair"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your own public key path
}

resource "aws_iam_instance_profile" "example_instance_profile" {
  name = "example-instance-profile"
  
  roles = [aws_iam_role.example_role.name]
}

resource "aws_iam_role" "example_role" {
  name = "example-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_ami" "example_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_instance" "example_instance" {
  ami           = data.aws_ami.example_ami.id
  instance_type = "m4.medium" # Replace with your desired instance type
  key_name      = aws_key_pair.example_keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.example_instance_profile.name
  security_groups = [aws_security_group.example_sg.name]
}

variable "bucket_name" {
  default = "your-bucket-name"
}

output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}
