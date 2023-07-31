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

def switch_primary_origin(distribution, profile_name):
    if 'Origins' in distribution and 'Items' in distribution['Origins']:
        origins = distribution['Origins']['Items']
        if len(origins) == 2:
            primary_origin_id = distribution['Origins']['Items'][0]['Id']
            new_primary_origin_id = distribution['Origins']['Items'][1]['Id']

            if 'CustomOriginConfig' in distribution['Origins']['Items'][0]:
                primary_origin_path = distribution['Origins']['Items'][0]['CustomOriginConfig'].get('OriginPath', '')
            else:
                primary_origin_path = ''

            session = boto3.Session(profile_name=profile_name)
            client = session.client('cloudfront')

            try:
                client.update_distribution(
                    Id=distribution['Id'],
                    DistributionConfig=distribution['DistributionConfig'],
                    IfMatch=distribution['ETag'],
                    DefaultRootObject=distribution['DefaultRootObject'],
                    Origins={
                        'Quantity': 2,
                        'Items': [
                            {
                                'Id': new_primary_origin_id,
                                'DomainName': distribution['Origins']['Items'][1]['DomainName'],
                                'OriginPath': '',
                                'CustomHeaders': distribution['Origins']['Items'][1]['CustomHeaders'],
                                'CustomOriginConfig': distribution['Origins']['Items'][1]['CustomOriginConfig']
                            },
                            {
                                'Id': primary_origin_id,
                                'DomainName': distribution['Origins']['Items'][0]['DomainName'],
                                'OriginPath': primary_origin_path,
                                'CustomHeaders': distribution['Origins']['Items'][0]['CustomHeaders'],
                                'CustomOriginConfig': distribution['Origins']['Items'][0]['CustomOriginConfig']
                            }
                        ]
                    }
                )
                print("Primary origin switched successfully.")
            except Exception as e:
                print(f"An error occurred while switching primary origin: {e}")
        else:
            print("The CloudFront distribution does not have exactly two origins.")
    else:
        print("The CloudFront distribution does not have any origins or has an invalid format.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Switch the primary origin for a CloudFront distribution.")
    parser.add_argument("distribution_id", type=str, help="The ID of the CloudFront distribution.")
    parser.add_argument("aws_profile", type=str, help="The AWS profile name from ~/.aws/credentials.")
    args = parser.parse_args()

    distribution_id = args.distribution_id
    aws_profile_name = args.aws_profile

    distribution = get_cloudfront_distribution(distribution_id, aws_profile_name)
    if distribution:
        switch_primary_origin(distribution, aws_profile_name)
