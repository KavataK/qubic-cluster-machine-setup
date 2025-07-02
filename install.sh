#!/bin/bash

set -e

# === Helper function ===
echo_info() {
    echo -e "\n\033[1;34m[INFO]\033[0m $1\n"
}

# === Step 1: Download and extract 32GBVHD.zip in background ===
echo_info "Downloading 32GBVHD.zip from Google Drive..."
gdown --id 1XioJ68w7YLWjx2CBDhOVuy-9oBYdh6a4 --no-cookies --quiet

echo_info "Extracting 32GBVHD.zip to /root (in background)..."
unzip -o 32GBVHD.zip -d /root/ &

bg_unzip_pid=$!

# === Step 2: Download and extract 154base.zip ===
echo_info "Downloading 154base.zip from Google Drive..."
gdown --id 1x2b_GIxOsLYSTwB1ZnERZVwi6TUPF59m --no-cookies --quiet

echo_info "Creating /root/filesForVHD and extracting 154base.zip..."
mkdir -p /root/filesForVHD
unzip -o 154base.zip -d /root/filesForVHD

# === Step 3: Install required packages ===
echo_info "Installing required packages..."

apt update
apt install -y freerdp2-x11 git docker.io libxcb-cursor0 sshpass \
    gcc-12 g++-12 dkms build-essential linux-headers-$(uname -r) \
    gcc make perl tree tmux

# === Step 4: Download and install VirtualBox ===
echo_info "Downloading and installing VirtualBox..."
wget https://download.virtualbox.org/virtualbox/7.1.4/virtualbox-7.1_7.1.4-165100~Ubuntu~jammy_amd64.deb
dpkg -i virtualbox-7.1_7.1.4-165100~Ubuntu~jammy_amd64.deb || apt -f install -y

# === Step 5: Download and install Extension Pack ===
echo_info "Downloading VirtualBox Extension Pack..."
wget https://download.virtualbox.org/virtualbox/7.1.4/Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack

echo_info "Installing Extension Pack..."
VBoxManage extpack install Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack --accept-license=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae

# === Step 6: Reconfigure VirtualBox Kernel Modules ===
modprobe -r vboxnetflt vboxnetadp vboxpci vboxdrv || true
/sbin/vboxconfig || true

# === Step 7: Clone qubic_docker repository ===
echo_info "Cloning qubic_docker repo to /root/"
git clone https://github.com/icyblob/qubic_docker.git /root/qubic_docker

# === Step 8: Clean up ===
echo_info "Removing installation files..."
rm -f virtualbox-7.1_7.1.4-165100~Ubuntu~jammy_amd64.deb
rm -f Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack
rm -f 32GBVHD.zip 154base.zip

# === Step 9: Wait for background unzip ===
echo_info "Waiting for background unzip process to finish..."
wait $bg_unzip_pid
echo_info "32GBVHD.zip successfully extracted."

echo_info "Setup completed successfully."

