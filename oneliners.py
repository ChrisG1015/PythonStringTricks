python -c "import json; data = json.load(open('your_json_file.json')); print(data.keys())"



import boto3

def get_last_updated_tag(security_group_id):
    ec2 = boto3.client('ec2')

    try:
        response = ec2.describe_tags(
            Filters=[
                {'Name': 'resource-id', 'Values': [security_group_id]},
                {'Name': 'key', 'Values': ['last_updated']}
            ]
        )

        tags = response['Tags']
        if tags:
            return tags[0]['Value']
        else:
            return None

    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    # Replace 'your_security_group_id' with the actual security group ID
    security_group_id = 'your_security_group_id'

    last_updated_tag = get_last_updated_tag(security_group_id)

    if last_updated_tag is not None:
        print(f"The 'last_updated' tag for Security Group {security_group_id} is: {last_updated_tag}")
    else:
        print(f"No 'last_updated' tag found for Security Group {security_group_id}")

