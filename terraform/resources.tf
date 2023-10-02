provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# Create an S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-lambda-s3-bucket"
  acl    = "private"
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach a policy to the IAM role that grants S3 permissions
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # Replace with a more restricted policy
  role       = aws_iam_role.lambda_role.name
}

# Create a Lambda function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda-function"
  filename     = "lambda_function.zip" # Replace with your Python script package
  source_code_hash = filebase64sha256("lambda_function.zip") # Replace with your Python script package

  handler = "lambda_function.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.example_bucket.id
    }
  }
}

# Grant Lambda permissions to interact with S3
resource "aws_lambda_permission" "s3_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.example_bucket.arn
}
