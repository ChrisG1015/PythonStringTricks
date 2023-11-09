prefix=$(echo "$url" | sed -n 's|\(https://.*amazon\.aws\.com\).*|\1|p')
suffix=$(echo "$url" | sed -n 's|https://.*amazon\.aws\.com\(/out/.*\)|\1|p')
aws lambda list-layers --query "Layers[?LayerName=='YourLayerName'].LayerArn" --output text
 "Layers": [
          { "Fn::ImportValue": { "Fn::Sub": "${LayerArnParameter}" } }
        ]


aws events put-rule --name "UpdateDistributionRule" --event-pattern "{\"source\": [\"aws.cloudtrail\"], \"detail\":{\"eventName\":[\"UpdateDistribution\"]}}"
aws cloudwatch put-metric-alarm --alarm-name "fast-UpdateDistributionAlarm" --alarm-description "fast-UpdateDistribution event detected" --actions-enabled --metric-name "EventCount" --namespace "AWS/Events" --statistic "SampleCount" --period 60 --threshold 1 --comparison-operator "GreaterThanOrEqualToThreshold" --evaluation-periods 1 --dimensions Name=RuleName,Value="fast-UpdateDistributionRule"


import boto3

# Initialize a Boto3 EC2 client
ec2_client = boto3.client('ec2')

# Define the tag key you want to search for
tag_key = "pizza-whitelist"

# Use the describe_security_groups method to list all security groups
response = ec2_client.describe_security_groups()

# Iterate through the security groups and filter those with the specified tag
for group in response['SecurityGroups']:
    for tag in group.get('Tags', []):
        if tag.get('Key') == tag_key:
            print(f"Security Group ID: {group['GroupId']}")
            print(f"Tag Key: {tag_key}, Value: {tag['Value']}\n")
