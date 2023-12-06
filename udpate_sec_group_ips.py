import boto3

def update_security_group(sec_group_id, new_cidr_list):
    ec2 = boto3.client('ec2')

    # Get the existing IP permissions for the security group
    response = ec2.describe_security_groups(GroupIds=[sec_group_id])
    existing_permissions = response['SecurityGroups'][0]['IpPermissions']

    # Extract existing CIDR IPs
    existing_cidrs = set()
    for permission in existing_permissions:
        for ip_range in permission.get('IpRanges', []):
            existing_cidrs.add(ip_range['CidrIp'])

    # Determine CIDR IPs to be added and removed
    cidrs_to_add = set(new_cidr_list) - existing_cidrs
    cidrs_to_remove = existing_cidrs - set(new_cidr_list)

    # Remove old CIDR IPs
    for cidr_to_remove in cidrs_to_remove:
        ec2.revoke_security_group_ingress(
            GroupId=sec_group_id,
            IpPermissions=[{
                'IpProtocol': '-1',
                'IpRanges': [{'CidrIp': cidr_to_remove}]
            }]
        )

    # Add new CIDR IPs
    for cidr_to_add in cidrs_to_add:
        ec2.authorize_security_group_ingress(
            GroupId=sec_group_id,
            IpPermissions=[{
                'IpProtocol': '-1',
                'IpRanges': [{'CidrIp': cidr_to_add}]
            }]
        )

# Example usage:
security_group_id = 'your_security_group_id'
new_cidr_list = ['1.2.3.4/32', '5.6.7.8/24', '9.10.11.12/32']
update_security_group(security_group_id, new_cidr_list)
