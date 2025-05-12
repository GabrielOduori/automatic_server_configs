#!/bin/bash
set -euo pipefail

start_time=$(date +%s)

# Define the log file
LOG_FILE="./deploy_setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1  # Redirect stdout and stderr to the log file

echo "Starting deployment process..."
echo "Log file: $LOG_FILE"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

# Check if the required environment variables are set
if [ -z "${REMOTE_USER:-}" ] || [ -z "${REMOTE_HOST:-}" ]; then
    echo "Error: REMOTE_USER and REMOTE_HOST must be set in the .env file."
    exit 1
fi

# Escape special characters in SUDO_PASSWORD
ESCAPED_PASSWORD=$(printf '%q' "$SUDO_PASSWORD")

# Check if the set_up directory exists
if [ ! -d "./set_up" ]; then
    echo "Error: The set_up directory does not exist."
    exit 1
fi

# Check if the main_setup.sh script exists
if [ ! -f "./set_up/main_setup.sh" ]; then
    echo "Error: The main_setup.sh script does not exist in the set_up directory."
    exit 1
fi

# Dynamically construct the remote path
REMOTE_PATH="/home/$REMOTE_USER"

echo "Step 1: Copying the set_up folder to the remote server..."
# scp -r ./server_config "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
scp -r ./set_up "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"


echo "Step 2: Making scripts executable on the remote server..."
ssh "$REMOTE_USER@$REMOTE_HOST" "chmod +x $REMOTE_PATH/set_up/utils/*.sh && chmod +x $REMOTE_PATH/set_up/main_setup.sh"

echo "Step 3: Running the setup scripts on the remote server with environment variables..."
ssh "$REMOTE_USER@$REMOTE_HOST" "SUDO_PASSWORD=$ESCAPED_PASSWORD REMOTE_USER='$REMOTE_USER' REMOTE_HOST='$REMOTE_HOST' bash -s" < ./set_up/main_setup.sh

echo "Setup process on the remote server is complete!"

endtime=$(date +%s)
runtime=$((endtime-start_time))
echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."
echo "All steps completed successfully!"
echo "You can now access your server at $REMOTE_USER@$REMOTE_HOST."
echo "Remember to check the logs for any errors or warnings during the setup process."
