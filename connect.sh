#!/bin/bash
set -euo pipefail

### --- CONFIGURE THESE VARIABLES ---
SSH_PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOT3yCo3R2OEmry35UGZclbqVpo8OI9FrYpSll+lSB4z severxak@protonmail.com"
TAILSCALE_AUTH_KEY="tskey-auth-kAXgXRWEys11CNTRL-zza4fwKQdSAdB5cVkgkfSAwHMzFiFDBP"
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"
### --------------------------------

# Error handling
trap 'echo "❌ ERROR: Script failed at line $LINENO"; exit 1' ERR

# Logging function with timestamps
log() {
  echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] $1\n"
}

# Stylish header
echo -e "\n===================================="
echo -e "     🚀 ARCK START — Server Setup 🚀"
echo -e "====================================\n"

# Ask for sudo password once
sudo -v

log "Updating & Upgrading System"
sudo apt-get update -y && sudo apt-get upgrade -y

log "Installing Essentials"
sudo apt-get install -y \
  nano git curl wget unzip ufw htop net-tools \
  ca-certificates gnupg lsb-release software-properties-common

log "Installing Build Tools & Monitoring Tools"
sudo apt-get install -y build-essential iftop iotop

log "Setting Timezone & Locale"
sudo timedatectl set-timezone "$TIMEZONE"
sudo apt-get install -y locales
sudo locale-gen "$LOCALE"

log "Setting up SSH server"
sudo apt-get install -y openssh-server
sudo systemctl enable ssh --now

# Configure SSH keys
log "Configuring SSH keys"
mkdir -p ~/.ssh
echo "$SSH_PUB_KEY" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Harden SSH daemon
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

log "Configuring Firewall (UFW)"
sudo ufw allow OpenSSH
sudo ufw --force enable

log "Installing Docker & Docker Compose"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Optional: install standalone docker-compose (binary)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo usermod -aG docker $USER

log "Installing Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey=${TAILSCALE_AUTH_KEY} --ssh

echo -e "\n===================================="
echo -e "     ✅ ARCK SETUP COMPLETE ✅"
echo -e "   🔄 Reboot recommended now!"
echo -e "====================================\n"
