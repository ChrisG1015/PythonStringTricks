import os
import sys
import datetime
import openai
import dotenv
import streamlit as st
import requests
import io

from audio_recorder_streamlit import audio_recorder

# Import API key from .env file
dotenv.load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")
databricks_url = os.getenv("WHISPER_MODEL_DATABRICKS_URL")

# Global variable to store the response
global_response = None

def transcribe(audio_file):
    transcript = openai.Audio.transcribe("whisper-1", audio_file)
    return transcript

def transcribe_audio(audio_bytes):
    """
    Transcribe the audio bytes.

    :param audio_bytes: The audio data in bytes
    :return: The transcribed text
    """
    global global_response  # Use the global response variable
    files = {'file': audio_bytes}
    try:
        with st.spinner('Transcribing audio...'):
            global_response = requests.post(databricks_url, files=files)
            global_response.raise_for_status()  # This will raise an HTTPError for bad responses
            
            transcript = global_response.json()
            return transcript["text"]
    except requests.exceptions.RequestException as e:
        # Log the error and response content for debugging
        st.error(f"An error occurred: {e}")
        if global_response is not None:
            st.error(f"Response content: {global_response.text}")
        return "An error occurred during transcription."

def display_logs():
    """
    Display the connection logs and response details.
    """
    if global_response:
        with st.expander("Connection Logs and Response Details"):
            st.write(f"Request URL: {global_response.url}")
            st.write(f"Request Headers: {global_response.request.headers}")
            st.write(f"Request Body: {global_response.request.body}")
            
            st.write(f"Response Status Code: {global_response.status_code}")
            st.write(f"Response Headers: {global_response.headers}")
            st.write(f"Response Content: {global_response.content}")

def save_audio_file(audio_bytes, file_extension="wav"):
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

def main():
    """
    Main function to run the Whisper Transcription app.
    """
    st.title("Whisper Transcription")

    tab1, tab2 = st.tabs(["Record Audio", "Upload Audio"])

    audio_bytes = None
    audio_file_name = None

    # Record Audio tab
    with tab1:
        audio_bytes = audio_recorder()
        if audio_bytes:
            st.audio(audio_bytes, format="audio/wav")
            st.write("Audio recorded successfully.")
            audio_file_name = save_audio_file(audio_bytes, "wav")
            st.write(f"Saved audio file: {audio_file_name}")
            st.write(f"Recording duration: {len(audio_bytes) / 16000:.2f} seconds")

    # Upload Audio tab
    with tab2:
        audio_file = st.file_uploader("Upload Audio", type=["mp3", "mp4", "wav", "m4a"])
        if audio_file:
            audio_bytes = audio_file.read()
            st.audio(audio_bytes, format="audio/wav")
            st.write("Audio uploaded successfully.")
            audio_file_name = save_audio_file(audio_bytes, audio_file.type.split('/')[1])
            st.write(f"Saved audio file: {audio_file_name}")

    # Transcribe button action
    if st.button("Transcribe") and audio_bytes:
        # Convert audio bytes to an in-memory file-like object
        audio_file = io.BytesIO(audio_bytes)
        audio_file.name = "audio.wav"

        # Transcribe the audio file
        transcript_text = transcribe_audio(audio_file)

        # Display the transcript
        st.header("Transcript")
        st.write(transcript_text)

        # Save the transcript to a text file
        with open("transcript.txt", "w") as f:
            f.write(transcript_text)

        # Provide a download button for the transcript
        st.download_button("Download Transcript", transcript_text)
    elif not audio_bytes:
        st.warning("Please record or upload an audio file before transcribing.")

    # Display connection logs
    display_logs()

if __name__ == "__main__":
    # Set up the working directory
    working_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(working_dir)

    # Run the main function
    main()
