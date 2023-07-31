import boto3
import pandas as pd

def get_cloudfront_data(profile_name):
    # Use the provided AWS profile for authentication
    session = boto3.Session(profile_name=profile_name)
    client = session.client('cloudfront')

    # Make the API call to get the CloudFront distributions
    response = client.list_distributions()

    # Extract the CloudFront ID and description from the response
    cloudfront_data = []
    for distribution in response['DistributionList']['Items']:
        cloudfront_id = distribution['Id']
        description = distribution['Comment']
        cloudfront_data.append({'CloudFrontID': cloudfront_id, 'Description': description})

    return cloudfront_data

def save_to_csv(data):
    # Save the data to a CSV file using Pandas
    df = pd.DataFrame(data)
    df.to_csv('cloudfront_data.csv', index=False)

if __name__ == "__main__":
    # Replace 'your_aws_profile_name' with the actual AWS profile name you want to use
    aws_profile_name = 'your_aws_profile_name'

    cloudfront_data = get_cloudfront_data(aws_profile_name)
    save_to_csv(cloudfront_data)
