#!/bin/bash
# NVIDIA Tesla P1000 Setup mit Treiber 560

echo "=== NVIDIA Tesla Setup ==="

# Alte Treiber entfernen
echo "Entferne alte Treiber..."
sudo apt-get purge -y nvidia* cuda*
sudo apt-get autoremove -y

# Neue Treiber installieren
echo "Installiere NVIDIA Treiber 560..."
sudo apt install -y \
    nvidia-utils-560-server \
    nvidia-driver-560-server \
    nvidia-dkms-560-server \
    nvidia-cuda-toolkit

# Kernel-Module laden
echo "Lade Kernel-Module..."
sudo modprobe nvidia
sudo modprobe nvidia-uvm

# GPU-Performance für Tesla P1000
echo "Konfiguriere GPU-Performance..."
for i in 0 1; do
    # Persistence Mode
    sudo nvidia-smi -i $i -pm 1
    
    # Power Limit für P1000
    sudo nvidia-smi -i $i -pl 250
    
    # Auto-Boost deaktivieren für konstante Performance
    sudo nvidia-smi -i $i --auto-boost-default=0
    
    # Memory und Graphics Clock
    sudo nvidia-smi -i $i -ac 5001,1590
done

# CUDA-Konfiguration
echo "Konfiguriere CUDA..."
echo 'export PATH="/usr/local/cuda/bin:$PATH"' | sudo tee -a /etc/profile.d/cuda.sh
echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' | sudo tee -a /etc/profile.d/cuda.sh
echo 'export CUDA_HOME="/usr/local/cuda"' | sudo tee -a /etc/profile.d/cuda.sh
echo 'export CUDA_VISIBLE_DEVICES="0,1"' | sudo tee -a /etc/profile.d/cuda.sh

# Status überprüfen
echo "GPU-Status:"
nvidia-smi

echo "=== NVIDIA Tesla Setup abgeschlossen ==="