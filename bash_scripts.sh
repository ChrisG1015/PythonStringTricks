prefix=$(echo "$url" | sed -n 's|\(https://.*amazon\.aws\.com\).*|\1|p')
suffix=$(echo "$url" | sed -n 's|https://.*amazon\.aws\.com\(/out/.*\)|\1|p')
aws lambda list-layers --query "Layers[?LayerName=='YourLayerName'].LayerArn" --output text
 "Layers": [
          { "Fn::ImportValue": { "Fn::Sub": "${LayerArnParameter}" } }
        ]


aws events put-rule --name "UpdateDistributionRule" --event-pattern "{\"source\": [\"aws.cloudtrail\"], \"detail\":{\"eventName\":[\"UpdateDistribution\"]}}"
aws cloudwatch put-metric-alarm --alarm-name "fast-UpdateDistributionAlarm" --alarm-description "fast-UpdateDistribution event detected" --actions-enabled --metric-name "EventCount" --namespace "AWS/Events" --statistic "SampleCount" --period 60 --threshold 1 --comparison-operator "GreaterThanOrEqualToThreshold" --evaluation-periods 1 --dimensions Name=RuleName,Value="fast-UpdateDistributionRule"


