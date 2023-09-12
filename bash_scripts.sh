prefix=$(echo "$url" | sed -n 's|\(https://.*amazon\.aws\.com\).*|\1|p')
suffix=$(echo "$url" | sed -n 's|https://.*amazon\.aws\.com\(/out/.*\)|\1|p')
aws lambda list-layers --query "Layers[?LayerName=='YourLayerName'].LayerArn" --output text
 "Layers": [
          { "Fn::ImportValue": { "Fn::Sub": "${LayerArnParameter}" } }
        ]

