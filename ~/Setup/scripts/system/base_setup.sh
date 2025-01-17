#!/bin/bash
# System-Basis-Setup

echo "=== System-Basis-Setup ==="

# System aktualisieren
sudo apt update
sudo apt upgrade -y

# Basis-Tools installieren
sudo apt install -y \
    build-essential \
    dkms \
    linux-headers-$(uname -r) \
    software-properties-common \
    wget \
    curl \
    git \
    htop \
    iotop \
    net-tools \
    pciutils \
    lm-sensors \
    nvme-cli

# Systemoptimierungen
sudo sysctl -w vm.swappiness=10
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216

# SSH-Server
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

echo "=== System-Basis-Setup abgeschlossen ==="