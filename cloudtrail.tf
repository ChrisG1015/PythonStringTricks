provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create an S3 bucket to store CloudWatch Logs
resource "aws_s3_bucket" "cloudwatch_logs_bucket" {
  bucket = "my-cloudwatch-logs-bucket" # Change to a unique bucket name
}

# Create a CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "cloudfront_log_group" {
  name = "cloudfront-origin-group-changes"
}

# Create a CloudWatch Metric Filter
resource "aws_cloudwatch_log_metric_filter" "origin_group_changes" {
  name            = "origin-group-changes"
  pattern         = "{ $.eventName = UpdateDistributionEvent && $.requestParameters.originGroups.changed = true }"
  log_group_name  = aws_cloudwatch_log_group.cloudfront_log_group.name

  metric_transformation {
    name      = "OriginGroupChanges"
    namespace = "Custom/CloudFront"
    value     = "1"
  }
}

# Create a CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "origin_group_changes_alarm" {
  alarm_name          = "origin-group-changes-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name         = "OriginGroupChanges"
  namespace           = "Custom/CloudFront"
  period              = 60
  statistic           = "SampleCount"
  threshold           = 1
  alarm_description   = "Origin Group Changes Detected"
  alarm_actions       = [aws_cloudwatch_log_group.cloudfront_log_group.arn]

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudfront_log_group.name
  }
}

# Permission for CloudWatch Logs to write to the S3 bucket
resource "aws_iam_policy" "cloudwatch_to_s3_policy" {
  name = "cloudwatch-to-s3-policy"

  description = "IAM policy to allow CloudWatch Logs to write to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
        ],
        Effect   = "Allow",
        Resource = aws_s3_bucket.cloudwatch_logs_bucket.arn
      }
    ]
  })
}

resource "aws_iam_role" "cloudwatch_to_s3_role" {
  name = "cloudwatch-to-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cloudwatch_to_s3_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_to_s3_policy.arn
  roles      = [aws_iam_role.cloudwatch_to_s3_role.name]
}

resource "aws_cloudwatch_log_resource_policy" "cloudwatch_to_s3_resource_policy" {
  policy_name = "cloudwatch-to-s3-resource-policy"
  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": "logs:PutSubscriptionFilter",
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudfront_log_group.name}:*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": "logs:DeleteSubscriptionFilter",
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudfront_log_group.name}:*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": "logs:DescribeSubscriptionFilters",
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudfront_log_group.name}:*"
    }
  ]
}
EOF
}

# Export CloudWatch Logs to the S3 bucket
resource "aws_cloudwatch_log_destination" "s3_export" {
  name                = "cloudfront-logs-export"
  target_arn          = aws_s3_bucket.cloudwatch_logs_bucket.arn
  role_arn            = aws_iam_role.cloudwatch_to_s3_role.arn
  destination_name    = "s3-export"
  destination_policy  = aws_cloudwatch_log_resource_policy.cloudwatch_to_s3_resource_policy.policy_document
}
