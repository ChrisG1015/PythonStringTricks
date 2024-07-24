import os
import sys
import datetime
import openai
import dotenv
import streamlit as st
import requests

from audio_recorder_streamlit import audio_recorder

# Import API key from .env file
dotenv.load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")
databricks_url = os.getenv("WHISPER_MODEL_DATABRICKS_URL")
audio_dir = "audio_files"

# Create the audio directory if it doesn't exist
if not os.path.exists(audio_dir):
    os.makedirs(audio_dir)

def transcribe(audio_file):
    transcript = openai.Audio.transcribe("whisper-1", audio_file)
    return transcript

def save_audio_file(audio_bytes, file_extension):
    """
    Save audio bytes to a file with the specified extension.

    :param audio_bytes: Audio data in bytes
    :param file_extension: The extension of the output audio file
    :return: The name of the saved audio file
    """
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = os.path.join(audio_dir, f"audio_{timestamp}.{file_extension}")

    with open(file_name, "wb") as f:
        f.write(audio_bytes)

    st.write(f"Saved audio file: {file_name}")  # Debug statement
    return file_name

def transcribe_audio(file_path):
    """
    Transcribe the audio file at the specified path.

    :param file_path: The path of the audio file to transcribe
    :return: The transcribed text
    """
    with open(file_path, "rb") as audio_file:
        files = {'file': audio_file}
        try:
            response = requests.post(databricks_url, files=files)
            response.raise_for_status()  # This will raise an HTTPError for bad responses
            transcript = response.json()
            return transcript["text"]
        except requests.exceptions.RequestException as e:
            # Log the error and response content for debugging
            st.error(f"An error occurred: {e}")
            st.error(f"Response content: {response.text}")
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
            audio_file_name = save_audio_file(audio_bytes, "wav")
            st.write(f"Recorded audio file saved as {audio_file_name}")

    # Upload Audio tab
    with tab2:
        audio_file = st.file_uploader("Upload Audio", type=["mp3", "mp4", "wav", "m4a"])
        if audio_file:
            file_extension = audio_file.type.split('/')[1]
            audio_file_name = save_audio_file(audio_file.read(), file_extension)
            st.write(f"Uploaded audio file saved as {audio_file_name}")

    # Transcribe button action
    if st.button("Transcribe"):
        # Find the newest audio file
        audio_files = [f for f in os.listdir(audio_dir) if f.startswith("audio")]
        if not audio_files:
            st.error("No audio files found.")
            return

        audio_file_path = max(audio_files, key=lambda x: os.path.getctime(os.path.join(audio_dir, x)))

        # Transcribe the audio file
        transcript_text = transcribe_audio(os.path.join(audio_dir, audio_file_path))

        # Display the transcript
        st.header("Transcript")
        st.write(transcript_text)

        # Save the transcript to a text file
        with open("transcript.txt", "w") as f:
            f.write(transcript_text)

        # Provide a download button for the transcript
        st.download_button("Download Transcript", transcript_text)

if __name__ == "__main__":
    # Set up the working directory
    working_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(working_dir)

    # Run the main function
    main()
