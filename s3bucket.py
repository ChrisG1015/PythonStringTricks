import os
import boto3

def upload_json_to_s3(json_file_path):
    try:
        # Get the S3 bucket name from the BUCKET_NAME environment variable
        bucket_name = os.environ.get("BUCKET_NAME")

        if not bucket_name:
            print("Error: BUCKET_NAME environment variable not set.")
            return

        # Initialize an S3 client
        s3_client = boto3.client('s3')

        # Extract the JSON file name from the path
        json_file_name = json_file_path.split('/')[-1]

        # Upload the JSON file to the specified S3 bucket
        s3_client.upload_file(json_file_path, bucket_name, json_file_name)

        print(f"Successfully uploaded {json_file_name} to {bucket_name}")

    except Exception as e:
        print(f"Error: {str(e)}")

# Replace 'your_json_file.json' with the path to your JSON file
json_file_path = 'your_json_file.json'

# Call the function to upload the JSON file
upload_json_to_s3(json_file_path)
