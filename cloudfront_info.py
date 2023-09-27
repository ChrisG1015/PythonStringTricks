import boto3
import json

# Initialize the AWS CloudFront client
client = boto3.client("cloudfront")

# Get a list of CloudFront distributions
response = client.list_distributions()

# Extract relevant information and store it in a list of dictionaries
distributions_info = []
for distribution in response["DistributionList"]["Items"]:
    distribution_info = {
        "ID": distribution["Id"],
        "Description": distribution["Comment"],
        "ARN": distribution["ARN"]
    }
    distributions_info.append(distribution_info)

# Save the information as a JSON file
with open("cloudfront_info.json", "w") as json_file:
    json.dump(distributions_info, json_file, indent=4)

print("CloudFront distribution information saved to cloudfront_info.json.")
