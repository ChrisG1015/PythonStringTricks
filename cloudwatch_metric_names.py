import boto3

# Initialize the CloudWatch client
cloudwatch = boto3.client('cloudwatch')

# List the available metric names
def list_metric_names():
    paginator = cloudwatch.get_paginator('list_metrics')
    for response in paginator.paginate():
        for metric in response['Metrics']:
            metric_name = metric['MetricName']
            namespace = metric['Namespace']
            print(f"Namespace: {namespace}, Metric Name: {metric_name}")

if __name__ == "__main__":
    list_metric_names()
This script creates a function called list_metric_names that uses a paginator to iterate through CloudWatch metrics and print their names and namespaces to the terminal. When you run the script, it will retrieve and display the metric names from your AWS account. Make sure your AWS credentials are properly configured to allow access to CloudWatch.





