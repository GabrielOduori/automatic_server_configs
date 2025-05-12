#!/bin/bash
set -euo pipefail

echo "Enabling automatic security updates..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades