#!/bin/bash

# Specify the MediaLive input security group ID
INPUT_SECURITY_GROUP_ID="YOUR_INPUT_SECURITY_GROUP_ID"

# Get the MediaLive channel ARN and ID
result=$(aws medialive list-inputs --query "Inputs[?InputSecurityGroups[?InputSecurityGroupId=='$INPUT_SECURITY_GROUP_ID']].{ID:Id, ARN:Arn}" --output json)

# Extract Channel ID and ARN from the result
CHANNEL_ID=$(echo "$result" | jq -r '.[0].ID')
CHANNEL_ARN=$(echo "$result" | jq -r '.[0].ARN')

# Output the results
echo "MediaLive Channel ID: $CHANNEL_ID"
echo "MediaLive Channel ARN: $CHANNEL_ARN"
