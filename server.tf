provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

resource "aws_security_group" "example_sg" {
  # ... (security group configuration)
}

resource "aws_key_pair" "example_keypair" {
  # ... (key pair configuration)
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

  # Define an inline policy with S3 permissions
  inline_policy {
    name = "example-s3-policy"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }
}

data "aws_ami" "example_ami" {
  # ... (AMI data source configuration)
}

resource "aws_instance" "example_instance" {
  # ... (EC2 instance configuration)
}

variable "bucket_name" {
  default = "your-bucket-name"
}

output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}



import pytest
from cafe_speech_copilot.src.main import transcribe, save_audio_file, transcribe_audio

def test_transcribe():
    # This is just a placeholder. You should replace it with actual testing logic.
    assert callable(transcribe)

def test_save_audio_file():
    # This is just a placeholder. You should replace it with actual testing logic.
    assert callable(save_audio_file)

def test_transcribe_audio():
    # This is just a placeholder. You should replace it with actual testing logic.
    assert callable(transcribe_audio)
