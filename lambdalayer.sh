#!/bin/bash

# Define variables
LAYER_NAME="google-cloud-layer"
LAYER_DESCRIPTION="Lambda Layer with Google Cloud Client Library"
PYTHON_VERSION="3.8"  # Choose the appropriate Python version
LAYER_ZIP="google_cloud_layer.zip"  # Temporary zip file for the layer content

# Create a temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Install the Google Cloud client library using pip
pip install google-cloud -t .

# Create a zip file containing the library
zip -r "$LAYER_ZIP" .

# Upload the Lambda Layer
aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "$LAYER_DESCRIPTION" \
  --compatible-runtimes "python$PYTHON_VERSION" \
  --zip-file "fileb://$LAYER_ZIP"

# Clean up temporary files
rm -rf "$TMP_DIR"
rm "$LAYER_ZIP"

echo "Lambda Layer '$LAYER_NAME' with the Google Cloud Client Library has been created."
