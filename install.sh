#!/bin/bash

set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Google Drive file IDs
FILE_ID_32GB="1XioJ68w7YLWjx2CBDhOVuy-9oBYdh6a4"
FILE_ID_BASE184="1LDpOtI7l5chRaFzCcQ5p498gmTEcU8pG"

echo "Installing gdown if not present..."
if ! command -v gdown &> /dev/null; then
    sudo apt update && sudo apt install -y python3-pip
    pip3 install gdown
fi

# Download the zip files
echo "Downloading 32GBVHD.zip from Google Drive..."
gdown --id "$FILE_ID_32GB" -O 32GBVHD.zip

echo "Downloading base184.zip from Google Drive..."
gdown --id "$FILE_ID_BASE184" -O base184.zip

# Unzip 32GBVHD.zip in background
echo "Unzipping 32GBVHD.zip in background to /root/..."
unzip -o 32GBVHD.zip -d /root/ > /dev/null &
ZIP_PID=$!

# Unzip base184.zip to /root/filesForVHD
echo "Creating /root/filesForVHD and unzipping base184.zip..."
mkdir -p /root/filesForVHD
unzip -o base184.zip -d /root/filesForVHD > /dev/null

# Install required packages
echo "Installing required packages..."

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y freerdp2-x11 git docker.io libxcb-cursor0 sshpass \
    gcc-12 g++-12 dkms build-essential linux-headers-$(uname -r) \
    gcc make perl tree tmux wget

# Create directory for qubic
sudo mkdir -p /mnt/qubic

# Download and install VirtualBox
echo "Downloading VirtualBox and extension pack..."
wget -q https://download.virtualbox.org/virtualbox/7.1.4/virtualbox-7.1_7.1.4-165100~Ubuntu~jammy_amd64.deb -O /tmp/virtualbox.deb
wget -q https://download.virtualbox.org/virtualbox/7.1.4/Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack -O /tmp/extpack.vbox-extpack

echo "Installing VirtualBox..."
sudo dpkg -i /tmp/virtualbox.deb || sudo apt-get install -f -y

echo "Installing VirtualBox Extension Pack..."
sudo VBoxManage extpack install Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack --accept-license=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae

# Configure VirtualBox kernel modules
sudo modprobe -r vboxnetflt vboxnetadp vboxpci vboxdrv || true
sudo /sbin/vboxconfig

# Clone qubic_docker
echo "Cloning Qubic Docker repository..."
git clone https://github.com/icyblob/qubic_docker.git /root/qubic_docker

# Wait for background unzip
echo "Waiting for 32GBVHD.zip unzip to finish..."
wait $ZIP_PID
echo "Unzipping of 32GBVHD.zip completed."

# Cleanup
echo "Cleaning up temporary files..."
rm -f 32GBVHD.zip base184.zip /tmp/virtualbox.deb /tmp/extpack.vbox-extpack

echo "Setup completed successfully!"
