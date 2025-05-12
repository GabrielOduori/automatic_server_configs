#!/bin/bash
set -euo pipefail

echo "Setting up Django environment..."

# Load environment variables from .env file
if [ -f ../../.env ]; then
    source ../../.env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Variables from .env
PROJECT_DIR_NAME=${PROJECT_DIR_NAME:-}  # Default to empty if not set
PROJECT_NAME=${PROJECT_NAME:-} 
USERNAME=${REMOTE_USER:-restoration_user}  # Use REMOTE_USER from .env or default to "restoration_user"

# Install Python and pip
echo "Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Create a virtual environment
echo "Creating a virtual environment for Django..."
sudo -u $USERNAME python3 -m venv /home/$USERNAME/$PROJECT_NAME-venv

# Activate the virtual environment and install dependencies
if [ -f /home/$USERNAME/$PROJECT_DIR_NAME/requirements.txt ]; then
    echo "Installing dependencies from requirements.txt..."
    sudo -u $USERNAME bash -c "source /home/$USERNAME/$PROJECT_NAME-venv/bin/activate && pip install -r /home/$USERNAME/$PROJECT_DIR_NAME/requirements.txt"
else
    echo "No requirements.txt found. Skipping dependency installation."
fi

echo "Django setup is complete. Your project is located at /home/$USERNAME/$PROJECT_DIR_NAME/$PROJECT_NAME."