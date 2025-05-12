#!/bin/bash
set -euo pipefail

echo "Setting up Gunicorn for Django..."

# Load environment variables from .env file
if [ -f ../../.env ]; then
    source ../../.env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Variables from .env
PROJECT_NAME=${PROJECT_NAME:-}  # Default to "myproject" if not set
USERNAME=${REMOTE_USER:-}  # Use REMOTE_USER from .env
PROJECT_DIR_NAME=${PROJECT_DIR_NAME:-}  # Default to PROJECT_NAME if not set


# Install virtualenv if not already installed
if ! command -v virtualenv &> /dev/null; then
    echo "virtualenv could not be found, installing..."
    sudo apt-get update
    sudo apt-get install -y python3-venv
else
    echo "virtualenv is already installed."
fi

# Activate the virtual environment and install Gunicorn
echo "Creating and activating virtual environment..."
sudo -u $USERNAME bash -c "python3 -m venv /home/$USERNAME/$PROJECT_NAME-venv"

# # Create a Gunicorn systemd service file
# echo "Creating Gunicorn systemd service file..."
# cat <<EOF | sudo tee /etc/systemd/system/$PROJECT_NAME.service
# [Unit]
# Description=gunicorn daemon for $PROJECT_NAME
# Requires=network.target
# After=network.target

# [Service]
# User=$USERNAME
# Group=www-data
# WorkingDirectory=/home/$USERNAME/$PROJECT_DIR_NAME/$PROJECT_NAME
# ExecStart=/home/$USERNAME/$PROJECT_NAME-venv/bin/gunicorn --workers 3 --bind unix:/home/$USERNAME/$PROJECT_NAME/$PROJECT_NAME.sock $PROJECT_NAME.wsgi:application

# [Install]
# WantedBy=multi-user.target
# EOF

# Lots of python process to ne done here



# AFTER creating the VM. we should copy or clone the project to the remote server

# run copy_project.sh to copy the project files from local computer to remote server



echo "Installing Gunicorn..."
sudo -u $USERNAME bash -c "source /home/$USERNAME/$PROJECT_NAME-venv/bin/activate && pip install --upgrade pip && pip install gunicorn psycopg2-binary"




# # sudo nano /etc/systemd/system/gunicorn.socket




echo "Creating Gunicorn systemd service file..."

cat <<EOF | sudo tee /etc/systemd/system/$PROJECT_NAME.service
[Unit]
Description=gunicorn daemon
Requires=network.target
After=network.target


Open gunicorn.service file

# sudo nano /etc/systemd/system/gunicorn.service

[Service]
User=$USERNAME
Group=www-data
WorkingDirectory=/home/$USERNAME/$PROJECT_DIR_NAME/$PROJECT_NAME
ExecStart=/home/$USERNAME/$PROJECT_NAME-venv/bin/gunicorn \\
    --workers 3 \\
    --bind unix:/home/$USERNAME/$PROJECT_NAME/$PROJECT_NAME.sock \\
    --access-logfile /home/$USERNAME/$PROJECT_NAME/access.log \\
    --error-logfile /home/$USERNAME/$PROJECT_NAME/error.log \\
    $PROJECT_NAME.wsgi:application
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
# Set permissions for the Gunicorn socket
echo "Setting permissions for the Gunicorn socket..."
sudo chown $USERNAME:www-data /home/$USERNAME/$PROJECT_NAME/$PROJECT_NAME.sock
sudo chmod 660 /home/$USERNAME/$PROJECT_NAME/$PROJECT_NAME.sock
# Reload systemd to apply changes
echo "Reloading systemd to apply changes..."
sudo systemctl daemon-reload
# Start Gunicorn

# Start and enable Gunicorn
echo "Starting and enabling Gunicorn..."
sudo systemctl start $PROJECT_NAME
sudo systemctl enable $PROJECT_NAME

echo "Gunicorn setup is complete. It is now serving your Django application."