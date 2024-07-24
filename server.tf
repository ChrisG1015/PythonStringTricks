import os
import sys
import datetime
import dotenv
import streamlit as st
import requests
import logging

from audio_recorder_streamlit import audio_recorder

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Import API key and Databricks URL from .env file
dotenv.load_dotenv()
databricks_url = os.getenv("WHISPER_MODEL_DATABRICKS_URL")

# Create a directory for storing audio files
audio_dir = "audio_files"
os.makedirs(audio_dir, exist_ok=True)

def save_audio_file(audio_bytes, file_extension):
    """
    Save audio bytes to a file with the specified extension.

    :param audio_bytes: Audio data in bytes
    :param file_extension: The extension of the output audio file
    :return: The name of the saved audio file
    """
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"{audio_dir}/audio_{timestamp}.{file_extension}"

    with open(file_name, "wb") as f:
        f.write(audio_bytes)

    logging.info(f"Audio saved to {file_name}")
    return file_name

def transcribe_audio(file_path):
    """
    Transcribe the audio file at the specified path using the Databricks model.

    :param file_path: The path of the audio file to transcribe
    :return: The transcribed text
    """
    logging.info(f"Transcribing audio file: {file_path}")
    with open(file_path, "rb") as audio_file:
        files = {'file': audio_file}
        try:
            with st.spinner('Transcribing audio...'):
                response = requests.post(databricks_url, files=files)
                response.raise_for_status()  # This will raise an HTTPError for bad responses
                logging.info(f"Response Status Code: {response.status_code}")
                logging.info(f"Response Headers: {response.headers}")
                logging.info(f"Response Content: {response.content}")

                transcript = response.json()
                return transcript["text"]
        except requests.exceptions.RequestException as e:
            st.error(f"An error occurred: {e}")
            logging.error(f"An error occurred: {e}")
            if response is not None:
                st.error(f"Response content: {response.text}")
                logging.error(f"Response content: {response.text}")
            return "An error occurred during transcription."

def main():
    """
    Main function to run the Whisper Transcription app.
    """
    st.title("Whisper Transcription")

    tab1, tab2 = st.tabs(["Record Audio", "Upload Audio"])

    # Record Audio tab
    with tab1:
        audio_bytes = audio_recorder()
        if audio_bytes:
            st.audio(audio_bytes, format="audio/wav")
            file_name = save_audio_file(audio_bytes, "wav")
            st.write(f"Saved audio file: {file_name}")
            logging.info(f"Audio recorded and saved as: {file_name}")

    # Upload Audio tab
    with tab2:
        audio_file = st.file_uploader("Upload Audio", type=["mp3", "mp4", "wav", "m4a"])
        if audio_file:
            file_extension = audio_file.type.split('/')[1]
            file_name = save_audio_file(audio_file.read(), file_extension)
            st.audio(audio_file, format="audio/wav")
            st.write(f"Saved audio file: {file_name}")
            logging.info(f"Audio uploaded and saved as: {file_name}")

    # Transcribe button action
    if st.button("Transcribe"):
        # Ensure the audio directory exists and contains files
        if not os.path.exists(audio_dir):
            st.error("Audio directory does not exist.")
            logging.error("Audio directory does not exist.")
            return

        audio_files = [f for f in os.listdir(audio_dir) if os.path.isfile(os.path.join(audio_dir, f)) and f.startswith("audio")]
        if not audio_files:
            st.error("No audio files found in the directory.")
            logging.error("No audio files found in the directory.")
            return

        logging.info(f"Audio files found: {audio_files}")

        # Find the newest audio file
        audio_file_path = max(
            [os.path.join(audio_dir, f) for f in audio_files],
            key=os.path.getct
