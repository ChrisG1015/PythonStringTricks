import argparse
import boto3

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
