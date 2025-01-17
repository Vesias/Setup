#!/bin/bash
# Automatisches System-Update-Skript

# Logging
log_file="/var/log/system_update.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== System-Update gestartet: $(date) ==="

# System aktualisieren
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean

# Kernel-Updates prüfen
if [ -f /var/run/reboot-required ]; then
    echo "HINWEIS: Neustart erforderlich"
fi

echo "=== System-Update abgeschlossen: $(date) ==="
