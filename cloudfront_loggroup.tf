provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Define the list of CloudFront distribution IDs
variable "cloudfront_distribution_ids" {
  type    = list(string)
  default = ["your-distribution-id-1", "your-distribution-id-2"]
}

# Create a CloudWatch Logs log group
resource "aws_cloudwatch_log_group" "cloudfront_logs" {
  name = "/aws/cloudfront/access-logs" # You can customize the log group name
}

# Configure each CloudFront distribution to send logs to the log group
resource "aws_cloudfront_distribution" "cloudfront_logs" {
  for_each = toset(var.cloudfront_distribution_ids)

  enabled = true
  comment = "CloudFront Distribution ${each.key}"

  # Specify your CloudFront distribution settings here

  logging_config {
    include_cookies = false
    prefix          = each.key

    # Configure the log group for each distribution
    bucket = aws_cloudwatch_log_group.cloudfront_logs.name
  }
}
