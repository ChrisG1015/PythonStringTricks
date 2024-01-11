provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

# IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# IAM Policy for Lambda Execution Role
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Policy for Lambda function"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name/*"  # Replace with your S3 bucket ARN
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach Lambda Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Security Group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Lambda Security Group"
}

# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "your-bucket-name"  # Replace with your desired bucket name
  acl    = "private"

  versioning {
    enabled = true
  }
}

# Lambda Function
resource "aws_lambda_function" "my_lambda_function" {
  function_name    = "my_lambda_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"  # Change to your desired runtime
  timeout          = 60
  memory_size      = 256
  source_code_hash = filebase64("${path.module}/lambda_function.zip")  # Zip your Lambda code
  
  environment = {
    variables = {
      S3_BUCKET = aws_s3_bucket.my_bucket.bucket
    }
  }
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name        = "lambda_trigger_rule"
  description = "Trigger Lambda every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.lambda_trigger.name
  arn  = aws_lambda_function.my_lambda_function.arn
}

# Allow Lambda to be triggered by EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn
}
