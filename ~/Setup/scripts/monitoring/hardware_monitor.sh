#!/bin/bash
# Hardware-Monitoring für Dual Tesla P100 und Xeon E5-2699 v3

# Logging
log_file="/var/log/hardware_monitor.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Hardware-Monitoring Start: $(date) ==="

# CPU-Monitoring
echo -e "\n=== CPU Status ==="
echo "CPU Frequenzen:"
for cpu in $(seq 0 35); do
    freq=$(cat /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_cur_freq)
    freq_ghz=$(echo "scale=2; $freq/1000000" | bc)
    echo "CPU $cpu: $freq_ghz GHz"
done

echo -e "\nCPU Temperaturen:"
sensors | grep "Core"

echo -e "\nCPU Last:"
mpstat -P ALL 1 1

echo -e "\nNUMA Status:"
numastat

# GPU-Monitoring
echo -e "\n=== GPU Status ==="
echo "GPU Power und Temperatur:"
nvidia-smi --query-gpu=index,name,temperature.gpu,power.draw,power.limit --format=csv,noheader

echo -e "\nGPU Auslastung:"
nvidia-smi --query-gpu=index,utilization.gpu,utilization.memory,memory.used,memory.total --format=csv,noheader

echo -e "\nGPU Prozesse:"
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader

# Speicher-Monitoring
echo -e "\n=== Speicher Status ==="
echo "Arbeitsspeicher:"
free -h
echo -e "\nSwap-Nutzung:"
swapon --show
echo -e "\nTop Speicherverbraucher:"
ps aux --sort=-%mem | head -n 6

# I/O-Monitoring
echo -e "\n=== I/O Status ==="
echo "Festplatten-Nutzung:"
df -h
echo -e "\nI/O Statistik:"
iostat -x 1 1

# Netzwerk-Monitoring
echo -e "\n=== Netzwerk Status ==="
echo "Netzwerk-Interfaces:"
ip -s link
echo -e "\nOffene Ports:"
ss -tuln
echo -e "\nNetzwerk-Statistik:"
netstat -s | head -n 20

# Performance-Metriken
echo -e "\n=== Performance-Metriken ==="
echo "Load Average:"
uptime
echo -e "\nProzess-Queue:"
vmstat 1 1

# CUDA-Status
echo -e "\n=== CUDA Status ==="
if command -v nvcc &> /dev/null; then
    echo "CUDA Version:"
    nvcc --version
    echo -e "\nCUDA Bibliotheken:"
    ldconfig -p | grep cuda
fi

# Systemd-Services
echo -e "\n=== Kritische Services ==="
systemctl status nvidia-persistenced --no-pager
systemctl status cpu-performance --no-pager

echo -e "\n=== Hardware-Monitoring Ende: $(date) ==="