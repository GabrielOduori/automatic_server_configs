#!/bin/bash
set -euo pipefail

echo "Copying Django project files from local computer to remote server..."

# Load environment variables from .env file
if [ -f ../../.env ]; then
    source ../../.env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Variables from .env
PROJECT_NAME=${PROJECT_NAME:-myproject}  # Default to "myproject" if not set
REMOTE_USER=${REMOTE_USER:-restoration_user}  # Use REMOTE_USER from .env or default to "restoration_user"
REMOTE_HOST=${REMOTE_HOST:-remote_host}  # Use REMOTE_HOST from .env or default to "remote_host"
LOCAL_PROJECT_PATH=${LOCAL_PROJECT_PATH:-}  # Path to the local project directory

# Dynamically determine PROJECT_DIR_NAME from LOCAL_PROJECT_PATH
if [ -n "$LOCAL_PROJECT_PATH" ]; then
    PROJECT_DIR_NAME=$(basename "$LOCAL_PROJECT_PATH")
else
    echo "Error: LOCAL_PROJECT_PATH is not set in the .env file."
    exit 1
fi

# Destination path on the remote server
REMOTE_PATH="/home/$REMOTE_USER/$PROJECT_DIR_NAME"

# Check if the local project directory exists
if [ ! -d "$LOCAL_PROJECT_PATH" ]; then
    echo "Error: Local project directory $LOCAL_PROJECT_PATH does not exist."
    exit 1
fi

# Copy the project files to the remote server
echo "Copying project files from $LOCAL_PROJECT_PATH to $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH..."
scp -r "$LOCAL_PROJECT_PATH" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"

echo "Project files copied successfully to $REMOTE_PATH on the remote server."