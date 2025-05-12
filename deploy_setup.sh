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

# #!/bin/bash
# set -euo pipefail

# start_time=$(date +%s)

# # Define the log file
# LOG_FILE="./deploy_setup.log"
# exec > >(tee -a "$LOG_FILE") 2>&1  # Redirect stdout and stderr to the log file

# echo "Starting deployment process..."
# echo "Log file: $LOG_FILE"

# # Load environment variables from .env file
# if [ -f .env ]; then
#     export $(grep -v '^#' .env | xargs)
# else
#     echo "Error: .env file not found!"
#     exit 1
# fi

# # Check if the required environment variables are set
# if [ -z "${REMOTE_HOST:-}" ] || [ -z "${ROOT_PASSWORD:-}" ] || [ -z "${NEW_USER:-}" ]; then
#     echo "Error: REMOTE_HOST, ROOT_PASSWORD, and NEW_USER must be set in the .env file."
#     exit 1
# fi

# # Dynamically construct the remote path
# REMOTE_PATH="/home/$NEW_USER/server_config"

# # Step 1: Log in as root and update the system
# echo "Step 1: Updating the system as root..."
# sshpass -p "$ROOT_PASSWORD" ssh -o StrictHostKeyChecking=no root@$REMOTE_HOST <<EOF
# apt update && apt upgrade -y
# EOF

# # Step 2: Set up SSH key authentication for root
# echo "Step 2: Setting up SSH key authentication for root..."
# sshpass -p "$ROOT_PASSWORD" ssh root@$REMOTE_HOST <<EOF
# mkdir -p ~/.ssh
# echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
# chmod 700 ~/.ssh
# chmod 600 ~/.ssh/authorized_keys
# EOF

# # Step 3: Create a new sudo user
# echo "Step 3: Creating a new sudo user ($NEW_USER)..."
# sshpass -p "$ROOT_PASSWORD" ssh root@$REMOTE_HOST <<EOF
# adduser --disabled-password --gecos "" $NEW_USER
# usermod -aG sudo $NEW_USER
# mkdir -p /home/$NEW_USER/.ssh
# cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
# chmod 700 /home/$NEW_USER/.ssh
# chmod 600 /home/$NEW_USER/.ssh/authorized_keys
# chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
# EOF

# # Step 4: Harden the server
# echo "Step 4: Hardening the server..."
# sshpass -p "$ROOT_PASSWORD" ssh root@$REMOTE_HOST <<EOF
# ufw allow OpenSSH
# ufw enable
# apt install unattended-upgrades fail2ban -y
# systemctl enable fail2ban
# EOF

# # Step 5: Disable root login
# echo "Step 5: Disabling root login..."
# sshpass -p "$ROOT_PASSWORD" ssh root@$REMOTE_HOST <<EOF
# sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
# sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
# systemctl restart sshd
# EOF

# # Step 6: Copy the setup folder to the remote server
# echo "Step 6: Copying the setup folder to the remote server..."
# scp -r ./set_up "$NEW_USER@$REMOTE_HOST:$REMOTE_PATH"

# # Step 7: Make scripts executable and run the main setup script
# echo "Step 7: Running the main setup script as the new user..."
# ssh "$NEW_USER@$REMOTE_HOST" <<EOF
# chmod +x $REMOTE_PATH/utils/*.sh
# chmod +x $REMOTE_PATH/main_setup.sh
# cd $REMOTE_PATH && ./main_setup.sh
# EOF

# echo "Setup process on the remote server is complete!"

# endtime=$(date +%s)
# runtime=$((endtime-start_time))
# echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."
# echo "All steps completed successfully!"
# echo "You can now access your server at $NEW_USER@$REMOTE_HOST."
# echo "Remember to check the logs for any errors or warnings during the setup process."


#!/bin/bash
# set -euo pipefail

# start_time=$(date +%s)

# # Define the log file
# LOG_FILE="./deploy_setup.log"
# exec > >(tee -a "$LOG_FILE") 2>&1  # Redirect stdout and stderr to the log file

# echo "Starting deployment process..."
# echo "Log file: $LOG_FILE"

# # Load environment variables from .env file
# if [ -f .env ]; then
#     export $(grep -v '^#' .env | xargs)
# else
#     echo "Error: .env file not found!"
#     exit 1
# fi

# # Extract REMOTE_USER and NEW_USER from the .env file
# if [ -z "${REMOTE_USER:-}" ] || [ -z "${NEW_USER:-}" ]; then
#     echo "Error: REMOTE_USER and NEW_USER must be set in the .env file."
#     exit 1
# fi

# # Check if the required environment variables are set
# if [ -z "${REMOTE_HOST:-}" ] || [ -z "${REMOTE_USER:-}" ]; then
#     echo "Error: REMOTE_HOST and REMOTE_USER must be set in the .env file."
#     exit 1
# fi

# # Dynamically construct the remote path
# REMOTE_PATH="/home/$NEW_USER/server_config"

# # Step 1: Log in as root and update the system
# echo "Step 1: Updating the system as root..."
# ssh -t root@$REMOTE_HOST <<EOF
# apt update && apt upgrade -y
# EOF

# # Step 2: Create a new sudo user
# echo "Step 2: Creating a new sudo user ($NEW_USER)..."
# ssh root@$REMOTE_HOST <<EOF
# adduser --disabled-password --gecos "" $NEW_USER
# usermod -aG sudo $NEW_USER
# mkdir -p /home/$NEW_USER/.ssh
# cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
# chmod 700 /home/$NEW_USER/.ssh
# chmod 600 /home/$NEW_USER/.ssh/authorized_keys
# chown -R "$REMOTE_USER:$REMOTE_USER" /home/$REMOTE_USER/.ssh
# EOF

# # Step 3: Harden the server
# echo "Step 3: Hardening the server..."
# ssh root@$REMOTE_HOST <<EOF
# ufw allow OpenSSH
# ufw enable
# apt install unattended-upgrades fail2ban -y
# systemctl enable fail2ban
# EOF

# # Step 4: Disable root login
# echo "Step 4: Disabling root login..."
# ssh root@$REMOTE_HOST <<EOF
# sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
# sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
# systemctl restart sshd
# EOF

# # Step 5: Copy the setup folder to the remote server
# echo "Step 5: Copying the setup folder to the remote server..."
# scp -r ./set_up "$NEW_USER@$REMOTE_HOST:$REMOTE_PATH"

# # Step 6: Make scripts executable and run the main setup script
# echo "Step 6: Running the main setup script as the new user..."
# ssh "$NEW_USER@$REMOTE_HOST" <<EOF
# chmod +x $REMOTE_PATH/utils/*.sh
# chmod +x $REMOTE_PATH/main_setup.sh
# cd $REMOTE_PATH && ./main_setup.sh
# EOF

# echo "Setup process on the remote server is complete!"

# endtime=$(date +%s)
# runtime=$((endtime-start_time))
# echo "Total runtime: $((runtime / 60)) minutes and $((runtime % 60)) seconds."
# echo "All steps completed successfully!"
# echo "You can now access your server at $NEW_USER@$REMOTE_HOST."
# echo "Remember to check the logs for any errors or warnings during the setup process."