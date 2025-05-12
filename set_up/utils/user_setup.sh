#!/bin/bash
set -euo pipefail

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found. Exiting."
    exit 1
fi

# Use environment variables
USERNAME=${REMOTE_USER:-}
COPY_AUTHORIZED_KEYS_FROM_ROOT="${COPY_AUTHORIZED_KEYS_FROM_ROOT:-true}"
IFS=',' read -r -a OTHER_PUBLIC_KEYS_TO_ADD <<< "${OTHER_PUBLIC_KEYS_TO_ADD:-}"

# Check if the group already exists and delete if necessary
if getent group "$USERNAME" &>/dev/null; then
    echo "Group $USERNAME already exists. Deleting the group..."
    sudo groupdel "$USERNAME"
fi

# Create the group
echo "Creating the group $USERNAME..."
sudo groupadd "$USERNAME"

# Check if the user already exists and delete if necessary
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists. Deleting the user..."
    sudo deluser --remove-home "$USERNAME"
fi

# Create a new user
echo "Creating a new user: $USERNAME"
sudo adduser --disabled-password --gecos "" "$USERNAME"
sudo usermod -aG sudo "$USERNAME"

# Add www-data to the restoration_user group
echo "Adding www-data to the $USERNAME group..."
sudo usermod -a -G "$USERNAME" www-data

# Set up SSH keys for the new user
echo "Setting up SSH keys for $USERNAME..."
home_directory="$(eval echo ~${USERNAME})"
sudo mkdir -p "${home_directory}/.ssh"

# Copy root's authorized_keys if requested
if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
    if [ -f /root/.ssh/authorized_keys ]; then
        echo "Copying root's authorized_keys to $USERNAME's .ssh directory..."
        sudo cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
    else
        echo "No root authorized_keys file found. Skipping copy."
    fi
fi

# Add additional public keys
echo "Adding additional public keys..."
for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
    if ! grep -q "${pub_key}" "${home_directory}/.ssh/authorized_keys" 2>/dev/null; then
        echo "${pub_key}" | sudo tee -a "${home_directory}/.ssh/authorized_keys" > /dev/null
    else
        echo "Key already exists in authorized_keys. Skipping: ${pub_key}"
    fi
done

# Set correct permissions and ownership
sudo chmod 0700 "${home_directory}/.ssh"
sudo chmod 0600 "${home_directory}/.ssh/authorized_keys"
sudo chown -R "${USERNAME}:${USERNAME}" "${home_directory}/.ssh"


echo "SSH keys setup complete for $USERNAME."

# #!/bin/bash
# set -euo pipefail

# # Load environment variables from .env file
# if [ -f .env ]; then
#     export $(grep -v '^#' .env | xargs)
# else
#     echo ".env file not found. Exiting."
#     exit 1
# fi

# # Use environment variables
# USERNAME="${REMOTE_USER:-}"
# COPY_AUTHORIZED_KEYS_FROM_ROOT="${COPY_AUTHORIZED_KEYS_FROM_ROOT:-true}"
# IFS=',' read -r -a OTHER_PUBLIC_KEYS_TO_ADD <<< "${OTHER_PUBLIC_KEYS_TO_ADD:-}"

# # Check if the password variable is set
# if [ -z "${SUDO_PASSWORD:-}" ]; then
#     echo "Error: SUDO_PASSWORD is not set. Please pass it as an environment variable."
#     exit 1
# fi

# # Create the group
# if ! getent group "$USERNAME" &>/dev/null; then
#     echo "Creating the group $USERNAME..."
#     groupadd "$USERNAME"
# fi

# # Create the user
# if ! id "$USERNAME" &>/dev/null; then
#     echo "Creating a new user: $USERNAME"
#     adduser --disabled-password --gecos "" "$USERNAME"
#     usermod -aG sudo "$USERNAME"
# fi

# # Add `www-data` to the user's group
# echo "Adding www-data to the $USERNAME group..."
# usermod -a -G "$USERNAME" www-data

# # Set up SSH keys for the new user
# echo "Setting up SSH keys for $USERNAME..."
# home_directory="$(eval echo ~${USERNAME})"
# mkdir -p "${home_directory}/.ssh"

# # Copy root's authorized_keys if requested
# if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
#     if [ -f /root/.ssh/authorized_keys ]; then
#         echo "Copying root's authorized_keys to $USERNAME's .ssh directory..."
#         cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
#     else
#         echo "No root authorized_keys file found. Skipping copy."
#     fi
# fi

# # Add additional public keys
# echo "Adding additional public keys..."
# for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
#     if ! grep -q "${pub_key}" "${home_directory}/.ssh/authorized_keys" 2>/dev/null; then
#         echo "${pub_key}" >> "${home_directory}/.ssh/authorized_keys"
#     else
#         echo "Key already exists in authorized_keys. Skipping: ${pub_key}"
#     fi
# done

# # Set correct permissions and ownership
# chmod 0700 "${home_directory}/.ssh"
# chmod 0600 "${home_directory}/.ssh/authorized_keys"
# chown -R "${USERNAME}:${USERNAME}" "${home_directory}/.ssh"

# echo "SSH keys setup complete for $USERNAME."