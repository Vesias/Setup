#!/bin/bash
# NVIDIA Tesla P100 Dual-GPU Setup

echo "=== NVIDIA Tesla P100 Setup ==="

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

# GPU-Performance für Tesla P100
echo "Konfiguriere GPU-Performance..."
for i in 0 1; do
    # Persistence Mode
    sudo nvidia-smi -i $i -pm 1
    
    # Power Limit für P100 (250W TDP)
    sudo nvidia-smi -i $i -pl 250
    
    # Auto-Boost deaktivieren für konstante Performance
    sudo nvidia-smi -i $i --auto-boost-default=0
    
    # Memory und Graphics Clock für P100
    sudo nvidia-smi -i $i -ac 715,1328
    
    # Compute Mode (Exclusive Process)
    sudo nvidia-smi -i $i -c EXCLUSIVE_PROCESS
done

# CUDA-Konfiguration für Multi-GPU
echo "Konfiguriere CUDA..."
cat << 'EOF' | sudo tee /etc/profile.d/cuda.sh
# CUDA Multi-GPU Setup
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
export CUDA_HOME="/usr/local/cuda"
export CUDA_VISIBLE_DEVICES="0,1"
export CUDA_DEVICE_MAX_CONNECTIONS=1
export CUDA_CACHE_PATH="/usr/local/cuda/cache"
export CUDA_CACHE_MAXSIZE=2147483648
EOF

# NVIDIA Persistence Daemon
sudo systemctl enable nvidia-persistenced
sudo systemctl start nvidia-persistenced

# Status überprüfen
echo "GPU-Status:"
nvidia-smi -q

echo "=== NVIDIA Tesla P100 Setup abgeschlossen ==="