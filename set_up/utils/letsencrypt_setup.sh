#!/bin/bash
set -euo pipefail

echo "Setting up Let's Encrypt with Certbot..."

# Load environment variables from .env file
if [ -f ../../.env ]; then
    source ../../.env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Variables from .env
SERVER_DOMAIN=${SERVER_DOMAIN:-}  # Use SERVER_NAME from .env or default to example.com
WWW_SERVER_DOMAIN=${WWW_SERVER_DOMAIN:-}  # Use WWW_SERVER_DOMAIN from .env or default to www.example.com
EMAIL=${EMAIL:-admin@example.com}  # Use EMAIL from .env or default to admin@example.com


#Install snapd and make sure snapd core is updated
echo "Installing snapd and updating core..."
sudo apt update
sudo apt install -y snapd
sudo snap install core
sudo snap refresh core


sudo apt remove certbot
sudo apt purge certbot
sudo apt autoremove

# Install Certbot and the Nginx plugin
echo "Installing Certbot and the Nginx plugin..."
# Install Certbot using snap
sudo snap install --classic certbot

# Create a symbolic link to the Certbot executable
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Confirm Nginx is running and its configuration is valid
echo "Checking Nginx status and configuration..."
sudo systemctl status nginx
sudo nginx -t



# Step 4 - Obtain an SSL certificateStep
echo "Obtaining an SSL certificate for $SERVER_NAME $WWW_SERVER_DOMAIN ..."
sudo certbot --nginx -d $SERVER_DOMAIN  -d $WWW_SERVER_DOMAIN --non-interactive --agree-tos -m $EMAIL


# Verify the certificate was obtained successfully
if [ $? -eq 0 ]; then
    echo "SSL certificate successfully obtained for $SERVER_DOMAIN."
else
    echo "Failed to obtain SSL certificate. Please check the Certbot logs for details."
    exit 1
fi

# Step 5 - Set up automatic certificate renewal

echo "Setting up automatic certificate renewal with a dry-run..."
# Test the renewal process

if sudo certbot renew --dry-run; then
    echo "Automatic certificate renewal is set up successfully."
else
    echo "Failed to set up automatic certificate renewal. Please check the Certbot logs for details."
    exit 1
fi

echo "Enable and start systemd timer for automatic renewal..."
# Enable and start the systemd timer for automatic renewal

echo "Setting up automatic certificate renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo "Let's Encrypt setup is complete. SSL is now enabled for $SERVER_DOMAIN."