#!/bin/bash
#!/bin/bash
set -euo pipefail

# # Load environment variables from .env file
# if [ -f ../../.env ]; then
#     source ../../.env
# else
#     echo "Error: .env file not found!"
#     exit 1
# fi

# # Check if the password variable is set
# if [ -z "${SUDO_PASSWORD:-}" ]; then
#     echo "Error: SUDO_PASSWORD is not set in the .env file."
#     exit 1
# fi

# echo "Updating and upgrading the system..."
# echo "$SUDO_PASSWORD" | sudo -S apt update && sudo -S apt full-upgrade -y



#!/bin/bash
set -euo pipefail

# Check if the password variable is set
if [ -z "${SUDO_PASSWORD:-}" ]; then
    echo "Error: SUDO_PASSWORD is not set. Please pass it as an environment variable."
    exit 1
fi

echo "Updating and upgrading the system..."
echo "$SUDO_PASSWORD" | sudo -S apt update && sudo -S apt full-upgrade -y