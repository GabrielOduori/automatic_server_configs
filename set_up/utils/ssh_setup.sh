#!/bin/bash
set -euo pipefail

echo "Configuring SSH..."
sudo sed -i 's/^#\(PermitRootLogin\) .*/\1 no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\(PasswordAuthentication\) .*/\1 no/' /etc/ssh/sshd_config
sudo systemctl restart ssh