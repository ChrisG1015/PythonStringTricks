import argparse
import json
import requests

# Define the base URL for TechEx Core API
BASE_URL = "https/{}/api".format("techex-core-hostname")  # Replace with your TechEx Core host name

# Define the authentication function
def authenticate(auth_code):
    auth_url = "{}/auth".format(BASE_URL)
    headers = {"Authorization": f"Bearer {auth_code}"}
    response = requests.get(auth_url, headers=headers)

    if response.status_code == 200:
        print("Authentication successful")
        return response.json()
    else:
        print("Authentication failed")
        return None

# Define a function to retrieve edges
def get_edges(auth_data):
    edges_url = "{}/edges".format(BASE_URL)
    headers = {"Authorization": f"Bearer {auth_data['token']}"}
    response = requests.get(edges_url, headers=headers)

    if response.status_code == 200:
        return response.json()
    else:
        return None

# Define a function to retrieve license settings
def get_license_settings(auth_data):
    license_url = "{}/license-settings".format(BASE_URL)
    headers = {"Authorization": f"Bearer {auth_data['token']}"}
    response = requests.get(license_url, headers=headers)

    if response.status_code == 200:
        return response.json()
    else:
        return None

def main():
    parser = argparse.ArgumentParser(description="TechEx Core API Client")
    parser.add_argument("hostname", help="TechEx Core host name")
    parser.add_argument("--auth-file", help="Path to JSON file containing the authentication code")

    args = parser.parse_args()

    # Set the TechEx Core host name based on the provided argument
    global BASE_URL
    BASE_URL = "https://{}/api".format(args.hostname)

    if args.auth_file:
        with open(args.auth_file, "r") as file:
            auth_data = json.load(file)
    else:
        print("Authentication file not provided. Please use the --auth-file flag.")
        return

    auth_data = authenticate(auth_data.get("token"))
    if auth_data:
        edges = get_edges(auth_data)
        license_settings = get_license_settings(auth_data)

        if edges:
            print("Edges:")
            print(edges)

        if license_settings:
            print("License Settings:")
            print(license_settings)

if __name__ == "__main__":
    main()
