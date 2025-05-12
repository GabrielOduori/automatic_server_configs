#!/bin/bash
set -euo pipefail

echo "Configuring the firewall..."
sudo ufw allow OpenSSH
sudo ufw --force enable