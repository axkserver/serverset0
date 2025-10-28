#!/bin/bash

# ============================================================
# Script: setup_ssh_remote.sh
# Purpose: Install SSH server and add your public key for access
# Usage: SSH_PUB_KEY="your_public_key_here" ./setup_ssh_remote.sh
# ============================================================

set -e

log() {
    echo -e "\n[INFO] $1"
}

# Check if SSH_PUB_KEY is set
if [ -z "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODIg/63n4r5teFc9cgIw8Y0Yg6utKW/pO2AhZqUi+zP serverxak@protonmail.com" ]; then
    echo "Error: SSH_PUB_KEY variable is not set."
    echo "Usage: SSH_PUB_KEY=\"$(cat ~/.ssh/id_rsa.pub)\" $0"
    exit 1
fi

log "Installing SSH server..."
# Detect package manager
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y openssh-server
elif command -v pacman &> /dev/null; then
    sudo pacman -Sy --noconfirm openssh
elif command -v dnf &> /dev/null; then
    sudo dnf install -y openssh-server
else
    echo "Unsupported package manager. Please install SSH server manually."
    exit 1
fi

sudo systemctl enable ssh --now || sudo systemctl enable sshd --now

log "Configuring SSH keys..."
mkdir -p "$HOME/.ssh"
echo "$SSH_PUB_KEY" >> "$HOME/.ssh/authorized_keys"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/authorized_keys"

log "SSH setup complete! You can now SSH into this device using your key."
