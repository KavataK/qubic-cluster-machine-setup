# Qubic Cluster Machine Setup

This project automates the preparation of a fresh Linux server to run nodes in a clustered environment.

## What It Does

The `install.sh` script performs the following actions:

1. Installs all necessary packages, Docker, VirtualBox, and dependencies.
2. Downloads ZIP archives from Google Drive:
   - `32GBVHD.zip`: extracted to `/root/` (runs in background)
   - `base184.zip`: extracted to `/root/filesForVHD`
3. Clones the Qubic Docker setup repository to `/root/qubic_docker`
4. Cleans up downloaded files

---

## Requirements

- Ubuntu 22.04+
- Sudo privileges

---

## Usage


   ```bash
   git clone https://github.com/KavataK/qubic-cluster-machine-setup.git
   cd qubic-cluster-machine-setup
   bash install.sh
