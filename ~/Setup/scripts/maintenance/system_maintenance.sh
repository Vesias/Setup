#!/bin/bash
# System-Wartung für HPC-Server

# Logging
log_file="/var/log/system_maintenance.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== System-Wartung Start: $(date) ==="

# System-Updates
echo -e "\n1. System-Updates"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean

# GPU-Wartung
echo -e "\n2. GPU-Wartung"
# Tesla P100 Reset und Optimierung
for i in 0 1; do
    echo "Optimiere GPU $i..."
    sudo nvidia-smi -i $i -pm 1
    sudo nvidia-smi -i $i -pl 250
    sudo nvidia-smi -i $i --auto-boost-default=0
    sudo nvidia-smi -i $i -ac 715,1328
done

# CUDA Cache bereinigen
echo "Bereinige CUDA Cache..."
rm -rf ~/.nv/ComputeCache/*
sudo rm -rf /root/.nv/ComputeCache/*

# CPU-Optimierung
echo -e "\n3. CPU-Optimierung"
# Performance Governor überprüfen
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    current_governor=$(cat $cpu)
    if [ "$current_governor" != "performance" ]; then
        echo "performance" | sudo tee $cpu
    fi
done

# Speicher-Optimierung
echo -e "\n4. Speicher-Optimierung"
# Cache leeren
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
# Swap optimieren
sudo swapoff -a
sudo swapon -a

# Festplatten-Wartung
echo -e "\n5. Festplatten-Wartung"
# SMART-Status prüfen
for drive in /dev/sd?; do
    echo "Prüfe $drive..."
    sudo smartctl -H $drive
done

# Dateisystem-Check
echo "Dateisystem-Check..."
for fs in $(df -h --output=source | grep "^/dev"); do
    sudo tune2fs -l $fs | grep -E "Mount count|Check interval"
done

# Log-Rotation
echo -e "\n6. Log-Rotation"
sudo journalctl --vacuum-time=7d
find /var/log -type f -name "*.log" -exec sudo truncate -s 0 {} \;

# Performance-Überprüfung
echo -e "\n7. Performance-Test"
# CPU-Test
echo "CPU-Performance:"
stress-ng --cpu 36 --timeout 5s --metrics-brief

# GPU-Test
echo "GPU-Performance:"
nvidia-smi --query-gpu=utilization.gpu,utilization.memory,temperature.gpu --format=csv -l 1 -c 1

# Netzwerk-Optimierung
echo -e "\n8. Netzwerk-Optimierung"
# TCP-Optimierungen
cat << EOF | sudo tee /etc/sysctl.d/99-network-tune.conf
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
EOF
sudo sysctl -p /etc/sysctl.d/99-network-tune.conf

# Service-Status
echo -e "\n9. Service-Status"
critical_services=(
    "nvidia-persistenced"
    "ssh"
    "cpu-performance"
)

for service in "${critical_services[@]}"; do
    status=$(systemctl is-active $service)
    if [ "$status" != "active" ]; then
        echo "Starte $service neu..."
        sudo systemctl restart $service
    fi
done

# Abschlussbericht
echo -e "\n=== Wartungsbericht ==="
echo "GPU-Status:"
nvidia-smi --query-gpu=temperature.gpu,power.draw,clocks.current.graphics --format=csv
echo -e "\nSpeicher-Status:"
free -h
echo -e "\nFestplatten-Status:"
df -h

echo "=== System-Wartung Ende: $(date) ==="