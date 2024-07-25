import os
import sys
import datetime
import dotenv
import streamlit as st
import requests
import json
from audio_recorder_streamlit import audio_recorder

# Import environment variables from .env file
dotenv.load_dotenv()
databricks_instance = os.getenv("DATABRICKS_INSTANCE")
databricks_pat = os.getenv("DATABRICKS_PAT")
endpoint_name = "your-endpoint-name"  # Replace with your actual endpoint name
databricks_url = f"{databricks_instance}/api/2.0/serving-endpoints/{endpoint_name}/invocations"

# Function to get OAuth token using PAT
def get_oauth_token(databricks_instance, databricks_pat):
    token_url = f"{databricks_instance}/api/2.0/token-management/tokens"
    headers = {
        "Authorization": f"Bearer {databricks_pat}",
        "Content-Type": "application/json"
    }
    response = requests.get(token_url, headers=headers)
    if response.status_code == 200:
        token_data = response.json()
        # Assuming the response JSON contains the OAuth token in the "access_token" field
        return token_data.get("access_token")
    else:
        raise Exception(f"Failed to get OAuth token: {response.status_code} - {response.text}")

# Get the OAuth token
try:
    oauth_token = get_oauth_token(databricks_instance, databricks_pat)
except Exception as e:
    print(f"Error obtaining OAuth token: {e}")
    sys.exit(1)

# Log window container
log_container = st.empty()

def create_tf_serving_json(data):
    """
    Create a TensorFlow Serving JSON payload from the data.

    :param data: The data to be converted
    :return: The JSON payload
    """
    return {'inputs': {name: data[name].tolist() for name in data.keys()} if isinstance(data, dict) else data.tolist()}

def score_model(data, oauth_token):
    """
    Send the data to the Databricks model endpoint for scoring.

    :param data: The data to be sent
    :param oauth_token: The OAuth token for authorization
    :return: The response from the Databricks API
    """
    headers = {
        'Authorization': f'Bearer {oauth_token}',
        'Content-Type': 'application/json'
    }
    data_json = json.dumps(data, allow_nan=True)
    response = requests.post(databricks_url, headers=headers, data=data_json)
    if response.status_code != 200:
        raise Exception(
            f'Request failed with status {response.status_code}, {response.text}')
    return response.json()

def log_message(message):
    """
    Append a message to the log window.

    :param message: The message to append
    """
    log_container.write(message)

def save_audio_file(audio_bytes, file_extension):
    """
    Save audio bytes to a file with the specified extension.

    :param audio_bytes: Audio data in bytes
    :param file_extension: The extension of the output audio file
    :return: The name of the saved audio file
    """
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"audio_{timestamp}.{file_extension}"

    with open(file_name, "wb") as f:
        f.write(audio_bytes)

    return file_name

def send_to_databricks(audio_file_path, oauth_token):
    """
    Send the audio file to the Databricks endpoint for transcription.

    :param audio_file_path: The path of the audio file to send
    :param oauth_token: The OAuth token for authorization
    :return: The response from the Databricks API
    """
    with open(audio_file_path, "rb") as f:
        audio_data = f.read()

    data = {
        "inputs": [
            {
                "name": "audio",
                "type": "string",
                "value": audio_data.hex()  # Convert binary data to a hex string for JSON compatibility
            }
        ]
    }

    response = score_model(data, oauth_token)
    return response

def main():
    """
    Main function to run the Whisper Transcription app.
    """
    st.title("CAFE SPEECH COPILOT TRANSCIBER")

    # Print the API key and URL for verification
    st.write("Databricks URL:", databricks_url)
    st.write("Databricks OAuth Token:", oauth_token[:6] + '...' + oauth_token[-4:])  # Partially mask the OAuth token for security

    tab1, tab2 = st.tabs(["Record Audio", "Upload Audio"])

    # Record Audio tab
    with tab1:
        audio_bytes = audio_recorder()
        if audio_bytes:
            st.audio(audio_bytes, format="audio/wav")
            save_audio_file(audio_bytes, "mp3")
            log_message("Audio recorded and saved locally.")

    # Upload Audio tab
    with tab2:
        audio_file = st.file_uploader(
            "Upload Audio", type=["mp3", "mp4", "wav", "m4a"])
        if audio_file:
            file_extension = audio_file.type.split('/')[1]
            save_audio_file(audio_file.read(), file_extension)
            log_message("Audio file uploaded and saved locally.")

    # Transcribe button action
    if st.button("Transcribe"):
        try:
            # Find the newest audio file
            audio_file_path = max(
                [f for f in os.listdir(".") if f.startswith("audio")],
                key=os.path.getctime,
            )
            log_message(f"Found audio file: {audio_file_path}")

            # Send the audio file to Databricks for transcription
            response = send_to_databricks(audio_file_path, oauth_token)
            log_message("Transcript successfully sent to Databricks.")
            transcript_text = response.get("transcript", "")

            # Display the transcript
            st.header("Transcript")
            st.write(transcript_text)

            # Save the transcript to a text file
            with open("transcript.txt", "w") as f:
                f.write(transcript_text)

            # Provide a download button for the transcript
            st.download_button("Download Transcript", transcript_text)

        except requests.exceptions.RequestException as e:
            log_message(f"Request error: {e}")
        except Exception as e:
            log_message(f"Error during transcription or Databricks request: {e}")

if __name__ == "__main__":
    # Set up the working directory
    working_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(working_dir)

    # Run the main function
    main()
