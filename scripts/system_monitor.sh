#!/bin/bash
# Systemüberwachungs-Skript

# Schwellenwerte
DISK_THRESHOLD=90
MEMORY_THRESHOLD=85
LOAD_THRESHOLD=5

# Logging
log_file="/var/log/system_monitor.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Systemüberwachung gestartet: $(date) ==="

# Festplattennutzung
disk_usage=$(df -h / | awk '/\// {print $5}' | sed 's/%//')
if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
    echo "WARNUNG: Festplattennutzung bei ${disk_usage}%"
fi

# Speichernutzung
memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
    echo "WARNUNG: Speichernutzung bei ${memory_usage}%"
fi

# System-Load
load=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | tr -d ' ')
if (( $(echo "$load > $LOAD_THRESHOLD" | bc -l) )); then
    echo "WARNUNG: System-Load bei $load"
fi

echo "=== Systemüberwachung abgeschlossen: $(date) ==="
