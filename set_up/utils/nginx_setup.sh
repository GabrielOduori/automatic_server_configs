#!/bin/bash
set -euo pipefail

echo "Installing and setting up Nginx..."

# Load environment variables from .env file
if [ -f ../../.env ]; then
    source ../../.env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Variables from .env
USERNAME=${REMOTE_USER:-}  # Use REMOTE_USER from .env or default to "domain_user_name"
SERVER_NAME=${SERVER_DOMAIN:-}  # Use SERVER_NAME from .env or default to example.com

# Install Nginx
sudo apt update
sudo apt install -y nginx

# Configure UFW to allow HTTP and HTTPS traffic
echo "Configuring UFW to allow HTTP and HTTPS traffic..."
sudo ufw allow 'Nginx Full'

# Enable and start Nginx
echo "Enabling and starting Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Setting up Nginx server block
echo "Creating a basic Nginx server block..."
sudo mkdir -p /var/www/$SERVER_DOMAIN/html
sudo chown -R $USERNAME:$USERNAME /var/www/$SERVER_DOMAIN/html
# Set permissions
# Ensure the directory is accessible by the web server
# This is important for Nginx to serve files correctly
# The permissions should be set to 755 for directories and 644 for files
# This allows the owner to read, write, and execute, while
sudo chmod -R 755 /var/www/$SERVER_DOMAIN

# Create a sample index.html file
cat <<EOF | sudo tee /var/www/$SERVER_DOMAIN/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to $SERVER_DOMAIN's Server</title>
</head>
<body>
    <h1>Success! Nginx is installed and serving content. Domain $SERVER_DOMAIN is working fine.</h1>
</body>
</html>
EOF

# Create an Nginx server block configuration
cat <<EOF | sudo tee /etc/nginx/sites-available/$SERVER_DOMAIN
server {
    listen 80;
    server_name $SERVER_DOMAIN www.$SERVER_DOMAIN $SERVER_IP;

    root /var/www/$SERVER_DOMAIN/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable the server block
echo "Enabling the Nginx server block..."
sudo ln -s /etc/nginx/sites-available/$SERVER_DOMAIN /etc/nginx/sites-enabled/

# Uncomment 'server_names_hash_bucket_size 64;' in /etc/nginx/nginx.conf
echo "Uncommenting 'server_names_hash_bucket_size 64;' in /etc/nginx/nginx.conf..."
sudo sed -i '/#\s*server_names_hash_bucket_size 64;/s/^#//' /etc/nginx/nginx.conf
# Test the Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t
sudo systemctl reload nginx

echo "Nginx setup is complete. Please replace '$SERVER_DOMAIN' with your actual domain name and IP address in /etc/nginx/sites-available/$USERNAME if needed."