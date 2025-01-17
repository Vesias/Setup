#!/bin/bash
# Master-Setup-Skript für HPC-Server
# Hardware: 2x Tesla P100, Xeon E5-2699 v3, 128GB RAM

# Logging
log_file="/var/log/master_setup.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Master-Setup Start: $(date) ==="

# Verzeichnis-Check
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Funktion für Fehlerbehandlung
handle_error() {
    echo "FEHLER: $1"
    echo "Zeitpunkt: $(date)"
    echo "Skript wird beendet."
    exit 1
}

# Berechtigungen setzen
echo "Setze Berechtigungen..."
chmod +x system/*.sh
chmod +x gpu/*.sh
chmod +x cpu/*.sh
chmod +x monitoring/*.sh
chmod +x maintenance/*.sh

# 1. System-Basis-Setup
echo -e "\n=== 1. System-Basis-Setup ==="
./system/base_setup.sh || handle_error "System-Basis-Setup fehlgeschlagen"

# 2. GPU-Setup
echo -e "\n=== 2. GPU-Setup ==="
./gpu/tesla_p100_setup.sh || handle_error "GPU-Setup fehlgeschlagen"

# 3. CPU-Setup
echo -e "\n=== 3. CPU-Setup ==="
./cpu/xeon_e5_2699_setup.sh || handle_error "CPU-Setup fehlgeschlagen"

# 4. Monitoring-Setup
echo -e "\n=== 4. Monitoring-Setup ==="
# Monitoring-Cronjob einrichten
(crontab -l 2>/dev/null; echo "*/5 * * * * $SCRIPT_DIR/monitoring/hardware_monitor.sh") | crontab -

# 5. Wartungs-Setup
echo -e "\n=== 5. Wartungs-Setup ==="
# Täglichen Wartungs-Cronjob einrichten
(crontab -l 2>/dev/null; echo "0 3 * * * $SCRIPT_DIR/maintenance/system_maintenance.sh") | crontab -

# Systemd-Services erstellen
# Hardware-Monitoring Service
cat << EOF | sudo tee /etc/systemd/system/hardware-monitoring.service
[Unit]
Description=Hardware Monitoring Service
After=network.target

[Service]
ExecStart=$SCRIPT_DIR/monitoring/hardware_monitor.sh
Type=simple
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

# Service aktivieren
sudo systemctl daemon-reload
sudo systemctl enable hardware-monitoring
sudo systemctl start hardware-monitoring

# Abschlussprüfung
echo -e "\n=== Abschlussprüfung ==="

# GPU-Check
echo "GPU-Status:"
nvidia-smi || handle_error "GPU nicht verfügbar"

# CPU-Check
echo -e "\nCPU-Status:"
lscpu | grep "CPU MHz" || handle_error "CPU-Informationen nicht verfügbar"

# Speicher-Check
echo -e "\nSpeicher-Status:"
free -h || handle_error "Speicher-Informationen nicht verfügbar"

# Service-Check
echo -e "\nService-Status:"
systemctl status hardware-monitoring --no-pager || handle_error "Monitoring-Service nicht aktiv"

echo -e "\n=== Setup-Zusammenfassung ==="
echo "1. System-Basis: Installiert und konfiguriert"
echo "2. GPU-Setup: Tesla P100 Dual-GPU konfiguriert"
echo "3. CPU-Setup: Xeon E5-2699 v3 optimiert"
echo "4. Monitoring: Automatisiert (alle 5 Minuten)"
echo "5. Wartung: Tägliche Wartung um 3 Uhr morgens"

echo -e "\n=== Master-Setup Ende: $(date) ==="
echo "Bitte führen Sie einen Systemneustart durch: 'sudo reboot'"