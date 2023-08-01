import argparse
import boto3

def switch_cloudfront_primary_origin(distribution_id, aws_profile_name, origins):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=aws_profile_name)
    client = session.client('cloudfront')

    try:
        # Get the current distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origins
        if 'Origins' in distribution_config and 'Items' in distribution_config['Origins']:
            origin_ids = [origin['Id'] for origin in distribution_config['Origins']['Items']]

            # Find the primary origin group ID from the given origin dictionary
            primary_origin_group_id = origins.get('PRIMARY ORIGIN GROUP', None)

            # Check if the primary origin group ID is found and is one of the origin IDs
            if primary_origin_group_id in origin_ids:
                # Set the new primary origin group
                distribution_config['OriginGroups']['Items'][0]['Id'] = primary_origin_group_id

                # Update the distribution configuration with the modified origin group
                client.update_distribution(
                    Id=distribution_id,
                    DistributionConfig=distribution_config,
                    IfMatch=response['ETag']
                )

                print("Primary origin switched successfully.")
            else:
                print("Primary origin group ID not found in the distribution's origin IDs.")

        else:
            print(f"Origins not found for CloudFront distribution '{distribution_id}'.")

    except boto3.client('cloudfront').exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Replace 'your_distribution_id' with the actual ID of your CloudFront distribution
    distribution_id = 'your_distribution_id'
    # Replace 'your_aws_profile_name' with the AWS profile name from ~/.aws/credentials
    aws_profile_name = 'your_aws_profile_name'

    # Replace the values in the 'origins' dictionary with actual origin group IDs
    origins = {
        'ORIGIN GROUPS': ["origin_group_id_1", "origin_group_id_2", "origin_group_id_3"],
        'PRIMARY ORIGIN GROUP': "origin_group_id_1",
        'SECONDARY ORIGIN GROUP': "origin_group_id_2"
    }

    switch_cloudfront_primary_origin(distribution_id, aws_profile_name, origins)




def switch_cloudfront_primary_origin(distribution_id, aws_profile_name, origins):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=aws_profile_name)
    client = session.client('cloudfront')

    try:
        # Get the current distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origin groups
        if 'OriginGroups' in distribution_config and 'Items' in distribution_config['OriginGroups']:
            origin_groups = distribution_config['OriginGroups']['Items']

            # Find the primary origin group ID from the given origin dictionary
            primary_origin_group_id = origins.get('PRIMARY ORIGIN GROUP', None)

            # Check if the primary origin group ID is found
            if primary_origin_group_id is not None:
                # Set the new primary origin group
                distribution_config['OriginGroups']['Items'][0]['Id'] = primary_origin_group_id

                # Update the distribution configuration with the modified origin group
                client.update_distribution(
                    Id=distribution_id,
                    DistributionConfig=distribution_config,
                    IfMatch=response['ETag']
                )

                print("Primary origin switched successfully.")
            else:
                print("Primary origin group not found in the origin dictionary.")

        else:
            print(f"Origin groups not found for CloudFront distribution '{distribution_id}'.")

    except boto3.client('cloudfront').exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")



def get_cloudfront_origin_groups(distribution_id, profile_name):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    try:
        # Get the current distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origin groups
        if 'OriginGroups' in distribution_config and 'Items' in distribution_config['OriginGroups']:
            origin_groups = distribution_config['OriginGroups']['Items']

            primary_origin_group_id = distribution_config.get('OriginGroups').get('Items')[0].get('Id')
            primary_origin_group = next(group for group in origin_groups if group['Id'] == primary_origin_group_id)

            result = {
                'ORIGIN GROUPS': origin_groups,
                'PRIMARY ORIGIN GROUP': primary_origin_group
            }

            return result

        # Return an empty dictionary if no origin groups are found
        return {}

    except boto3.client('cloudfront').exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
        return {}
    except Exception as e:
        print(f"An error occurred: {e}")
        return {}

def get_cloudfront_distribution(distribution_id, profile_name):
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')
    try:
        response = client.get_distribution(Id=distribution_id)
        return response['Distribution']
    except client.exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def get_cloudfront_origin_groups(distribution_id, profile_name):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    try:
        # Get the current distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origin groups
        if 'OriginGroups' in distribution_config and 'Items' in distribution_config['OriginGroups']:
            origin_groups = distribution_config['OriginGroups']['Items']

            primary_origin_group = distribution_config['OriginGroups'].get('Quantity', 0)

            result = {
                'ORIGIN GROUPS': origin_groups,
                'PRIMARY ORIGIN GROUP': primary_origin_group
            }

            return result

        # Return an empty dictionary if no origin groups are found
        return {}

    except boto3.client('cloudfront').exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
        return {}
    except Exception as e:
        print(f"An error occurred: {e}")
        return {}



def get_cloudfront_origin_domains(distribution_id, profile_name):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    try:
        # Get the current distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origins and retrieve their domain names
        if 'Origins' in distribution_config and 'Items' in distribution_config['Origins']:
            origin_domains = [origin['DomainName'] for origin in distribution_config['Origins']['Items']]
            return origin_domains

        # Return an empty list if no origins are found
        return []

    except boto3.client('cloudfront').exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
        return []
    except Exception as e:
        print(f"An error occurred: {e}")
        return []



def set_cloudfront_primary_origin(distribution_id, new_domain_name, profile_name):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    try:
        # Get the current distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origins and retrieve their configurations
        if 'Origins' in distribution_config and 'Items' in distribution_config['Origins']:
            origins = distribution_config['Origins']['Items']

            # Find the primary origin and update its domain name
            for origin in origins:
                if 'CustomOriginConfig' in origin:
                    primary_origin_path = origin['CustomOriginConfig'].get('OriginPath', '')
                else:
                    primary_origin_path = ''

                origin['DomainName'] = new_domain_name
                origin['OriginPath'] = primary_origin_path

            # Update the distribution configuration with the modified origin information
            client.update_distribution(
                Id=distribution_id,
                DistributionConfig=distribution_config,
                IfMatch=response['ETag']
            )

            print(f"Primary origin for CloudFront distribution '{distribution_id}' set to '{new_domain_name}' successfully.")
        else:
            print(f"No origin found for CloudFront distribution '{distribution_id}'.")

    except boto3.client('cloudfront').exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


def get_cloudfront_origin_domains(distribution_id, profile_name):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    try:
        # Get the distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origins and retrieve their domain names
        if 'Origins' in distribution_config and 'Items' in distribution_config['Origins']:
            origin_domains = [origin['DomainName'] for origin in distribution_config['Origins']['Items']]
            return origin_domains

        # Return an empty list if no origins are found
        return []

    except client.exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None


def get_cloudfront_primary_origin(distribution_id, profile_name):
    # Create a Boto3 CloudFront client
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    try:
        # Get the distribution configuration
        response = client.get_distribution(Id=distribution_id)
        distribution_config = response['Distribution']['DistributionConfig']

        # Check if the distribution has origins and retrieve the primary origin domain
        if 'Origins' in distribution_config and 'Items' in distribution_config['Origins']:
            primary_origin_domain = distribution_config['Origins']['Items'][0]['DomainName']
            return primary_origin_domain

        # Return None if no origins are found
        return None

    except client.exceptions.NoSuchDistribution:
        print(f"CloudFront distribution with ID '{distribution_id}' not found.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
        
def switch_primary_origin(distribution, profile_name, new_flag):
    if 'Origins' in distribution and 'Items' in distribution['Origins']:
        primary_origin = distribution['Origins']['Items'][0]

        # Get the current primary origin domain name
        current_domain_name = primary_origin['DomainName']

        if new_flag not in current_domain_name:
            new_domain_name = current_domain_name.replace("east", "west") if "east" in current_domain_name else current_domain_name.replace("west", "east")

            try:
                session = boto3.Session(profile_name=profile_name)
                client = session.client('cloudfront')

                # Update the primary origin domain name
                primary_origin['DomainName'] = new_domain_name

                # Set the updated primary origin
                client.update_distribution(
                    Id=distribution['Id'],
                    DistributionConfig=distribution['DistributionConfig'],
                    IfMatch=distribution['ETag']
                )

                print(f"Primary origin switched successfully for distribution '{distribution['Id']}'.")
            except Exception as e:
                print(f"An error occurred while switching primary origin for distribution '{distribution['Id']}': {e}")
        else:
            print(f"Primary origin already contains '{new_flag}' in the domain name for distribution '{distribution['Id']}'.")

    else:
        print(f"Invalid CloudFront distribution format for distribution '{distribution['Id']}'.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Switch the primary origin for CloudFront distributions.")
    parser.add_argument("flag", choices=["west", "east"], help="The flag to check in the domain name.")
    parser.add_argument("distribution_ids", nargs="+", type=str, help="List of CloudFront distribution IDs.")
    parser.add_argument("--aws_profile", type=str, default="default", help="The AWS profile name from ~/.aws/credentials. (default: 'default')")
    args = parser.parse_args()

    new_flag = args.flag
    aws_profile_name = args.aws_profile
    distribution_ids = args.distribution_ids

    for distribution_id in distribution_ids:
        distribution = get_cloudfront_distribution(distribution_id, aws_profile_name)
        if distribution:
            switch_primary_origin(distribution, aws_profile_name, new_flag)
