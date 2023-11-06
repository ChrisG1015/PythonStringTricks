aws ec2 create-security-group \
    --group-name MySecurityGroup \
    --description "My security group with no publicly open CIDR blocks" \
    --vpc-id YourVpcId


aws ec2 authorize-security-group-ingress \
    --group-name MySecurityGroup \
    --protocol tcp \
    --port 22 \
    --cidr YourIpAddress/32
