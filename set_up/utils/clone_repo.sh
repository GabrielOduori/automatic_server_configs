#!/bin/bash
set -euo pipefail

echo "Cloning the repository from GitHub..."

# Load environment variables from .env file
if [ -f ../../.env ]; then
    source ../../.env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Variables from .env
REPO_URL=${REPO_URL:-}  # Repository URL from .env
REPO_BRANCH=${REPO_BRANCH:-main}  # Repository branch from .env (default to "main")
GITHUB_USERNAME=${GITHUB_USERNAME:-}  # GitHub username from .env
GITHUB_TOKEN=${GITHUB_TOKEN:-}  # GitHub token from .env
PROJECT_NAME=${PROJECT_NAME:-myproject}  # Project name from .env
USERNAME=${REMOTE_USER:-restoration_user}  # Remote user from .env

# Check if REPO_URL is provided
if [ -z "$REPO_URL" ]; then
    echo "Error: REPO_URL is not set in the .env file."
    exit 1
fi

# Check if GITHUB_TOKEN is provided
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is not set in the .env file."
    exit 1
fi

# Construct the authenticated repository URL
AUTHENTICATED_REPO_URL=$(echo "$REPO_URL" | sed "s|https://|https://$GITHUB_USERNAME:$GITHUB_TOKEN@|")

# Clone the repository
echo "Cloning the repository from $REPO_URL (branch: $REPO_BRANCH)..."
sudo -u $USERNAME git clone --branch $REPO_BRANCH $AUTHENTICATED_REPO_URL /home/$USERNAME/$PROJECT_NAME

echo "Repository cloned successfully to /home/$USERNAME/$PROJECT_NAME."