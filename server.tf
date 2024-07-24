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


Traceback:
File "/opt/app-root/lib64/python3.11/site-packages/streamlit/runtime/scriptrunner/script_runner.py", line 535, in _run_script
    exec(code, module.__dict__)
File "/app/src/main.py", line 107, in <module>
    main()
File "/app/src/main.py", line 87, in main
    transcript_text = transcribe_audio(audio_file_path)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File "/app/src/main.py", line 49, in transcribe_audio
    response.raise_for_status()
File "/opt/app-root/lib64/python3.11/site-packages/requests/models.py", line 1024, in raise_for_status
    raise HTTPError(http_error_msg, response=self)
