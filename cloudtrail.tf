provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create an S3 bucket
resource "aws_s3_bucket" "cloudfront_bucket" {
  bucket = "my-cloudfront-bucket" # Change to a unique bucket name
}

# Create a CloudTrail
resource "aws_cloudtrail" "cloudtrail" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudfront_bucket.id
  include_global_service_events = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type = "All"
  }

  # Define the CloudTrail data event selector for CloudFront origin ID changes
  event_selector {
    read_write_type = "WriteOnly"
    include_management_events = true

    data_resource {
      type   = "AWS::CloudFront::Distribution"
      values = ["OriginId"]
    }
  }
}

# Create an IAM policy to grant access to the S3 bucket
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = [aws_s3_bucket.cloudfront_bucket.arn]
  }
}

# Create an IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the S3 bucket policy to the IAM role
resource "aws_iam_policy_attachment" "s3_bucket_attachment" {
  policy_arn = aws_s3_bucket.cloudfront_bucket.arn
  name       = "s3-policy-attachment"
  roles      = [aws_iam_role.cloudtrail_role.name]
}

# Create the CloudTrail resource
resource "aws_cloudtrail" "cloudtrail_monitor" {
  name                          = "my-cloudtrail-monitor"
  s3_bucket_name                = aws_s3_bucket.cloudfront_bucket.id
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true

  event_selector {
    read_write_type = "All"
  }

  event_selector {
    read_write_type = "WriteOnly"
    include_management_events = true

    data_resource {
      type   = "AWS::CloudFront::Distribution"
      values = ["OriginId"]
    }
  }

  # Specify the IAM role for CloudTrail
  depends_on = [aws_iam_policy_attachment.s3_bucket_attachment]
  role_arn   = aws_iam_role.cloudtrail_role.arn
}
