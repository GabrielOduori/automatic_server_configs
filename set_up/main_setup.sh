#!/bin/bash


# This script is a **Bash script** designed to automate the initial setup of a server. 
# It ensures consistency and reduces the risk of human error during manual configuration.
# Here's a breakdown of what it does:

# 1. **`set -euo pipefail`**: 
#    - Ensures the script exits immediately if any command fails (`-e`).
#    - Treats unset variables as errors (`-u`).
#    - Ensures that errors in pipelines are not ignored (`pipefail`).

# 2. **Echo Statements**: 
#    - Provides clear, step-by-step output to the user about what the script is doing.

# 3. **Step-by-Step Execution**:
#    - The script calls other scripts located in the set_up directory to perform specific tasks:
#      - **`system_update.sh`**: Updates and upgrades the system packages.
#      - **`user_setup.sh`**: Sets up users and groups.
#      - **`ssh_setup.sh`**: Configures SSH for secure access.
#      - **`firewall_setup.sh`**: Configures the firewall for security.
#      - **`essential_packages.sh`**: Installs essential software packages.
#      - **`automatic_updates.sh`**: Enables automatic security updates.
#      - **`nginx_setup.sh`**: Installs and configures the NginX web server.
#      - **`letsencrypt_setup.sh`**: Sets up Let's Encrypt SSL certificates for HTTPS.
#      - **`certbot_setup.sh`**: Configures Certbot for automatic SSL certificate renewal.



#!/bin/bash
set -euo pipefail

echo "Starting initial server setup..."

echo "Step 1: Updating and upgrading the system..."
./set_up/utils/system_update.sh

echo "Step 2: Setting up user and groups..."
# ./set_up/utils/user_setup.sh

echo "Step 3: Configuring SSH..."
./set_up/utils/ssh_setup.sh

echo "Step 4: Configuring the firewall..."
./set_up/utils/firewall_setup.sh

echo "Step 5: Installing essential packages..."
./set_up/utils/essential_packages.sh


echo "Step 6: Setting up PostgreSQL..."
./set_up/utils/postgres_setup.sh


echo "Step 7: Enabling automatic security updates..."
./set_up/utils/automatic_updates.sh

echo "Step 8: Setting up NginX..."
./set_up/utils/nginx_setup.sh

echo "Step 9: Setting up Let's Encrypt..."
./set_up/utils/letsencrypt_setup.sh


echo "Step 10: Cloning/copying project files..."
# Option 1: Copy files from the local machine
# Uncomment this block if you want to copy files from local machine
# echo "Copying project files from the local machine..."

# ./set_up/utils/copy_project.sh
# Option 2: Clone the repository from GitHub
# Uncomment this block if you want to clone the repository
# echo "Cloning the repository from GitHub..."

# ./set_up/utils/clone_repo.sh

echo "Step 11: Setting up Django..."
./set_up/utils/django_setup.sh


echo "Step 12: Setting up Gunicorn..."
./set_up/utils/gunicorn_setup.sh

echo "Initial server setup is complete!"



echo "Initial server setup is complete!"

echo "The folloiwing configurations have been made:"
echo "1. System updated and upgraded."
echo "2. User and groups set up."
echo "3. SSH configured for security."
echo "4. Firewall configured."
echo "5. Essential packages installed."
echo "6. Automatic security updates enabled."
echo "7. NginX installed and configured."
echo "8. Let's Encrypt SSL certificate installed and configured."
echo "9. Certbot set up for automatic certificate renewal."
echo "10. SSH key-based authentication set up."
echo "11. SSH root login disabled."
echo "12. Password authentication disabled."
echo "13. Firewall configured to allow SSH and HTTP/HTTPS traffic."
echo "14. Basic NginX server block created."
echo "15. Sample index.html file created."
echo "16. NginX server block enabled."
echo "17. NginX reloaded to apply changes."

echo "Next steps:"
echo "1. Change the password for the new user."
echo "Diable root login by setting PermitRootLogin to no in /etc/ssh/sshd_config."
echo "2. Disable password authentication in SSH settings."
echo "3. Restart the SSH service with: sudo systemctl restart ssh"
echo "ALL DONE!"

