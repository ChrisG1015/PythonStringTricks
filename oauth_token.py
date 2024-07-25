import os
import requests

# Load environment variables
databricks_instance = os.getenv("DATABRICKS_INSTANCE")
databricks_pat = os.getenv("DATABRICKS_PAT")

# Define the URL to obtain the OAuth token
oauth_url = f"{databricks_instance}/api/2.0/token-management/tokens"

# Set the headers for the request
headers = {
    "Authorization": f"Bearer {databricks_pat}",
    "Content-Type": "application/json"
}

# Make the request to get the OAuth token
response = requests.get(oauth_url, headers=headers)

# Check the response
if response.status_code == 200:
    # Parse the response to get the OAuth token
    token_data = response.json()
    oauth_token = token_data.get("access_token")
    print("OAuth Token:", oauth_token)
else:
    print(f"Failed to get OAuth token: {response.status_code} - {response.text}")
