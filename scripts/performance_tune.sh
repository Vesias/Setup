#!/bin/bash
# Performance-Optimierungs-Skript

# Logging
log_file="/var/log/performance_tune.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Performance-Optimierung gestartet: $(date) ==="

# CPU-Gouvernor auf Performance setzen
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Swappiness reduzieren
sudo sysctl vm.swappiness=10

# TCP-Optimierungen
sudo sysctl -w net.ipv4.tcp_fastopen=3
sudo sysctl -w net.core.default_qdisc=fq
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr

# Inotify-Limits erhöhen
sudo sysctl -w fs.inotify.max_user_watches=524288

echo "=== Performance-Optimierung abgeschlossen: $(date) ==="
