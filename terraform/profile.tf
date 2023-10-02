provider "aws" {
  region                  = "us-east-1" # Replace with your desired AWS region
  profile                 = "my-aws-profile" # Replace with your AWS CLI profile name
  shared_credentials_file = "~/.aws/credentials" # Replace with the path to your AWS credentials file
}
