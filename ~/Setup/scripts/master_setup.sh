#!/bin/bash
# Master-Setup-Skript für HPC-Server
# Hardware: 2x Tesla P100, Xeon E5-2699 v3, 128GB RAM

# Logging
log_file="$HOME/master_setup.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Master-Setup Start: $(date) ==="

# Verzeichnis-Check
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Funktion für Fehlerbehandlung
handle_error() {
    echo -e "${RED}FEHLER: $1${NC}"
    echo "Zeitpunkt: $(date)"
    echo "Skript wird beendet."
    exit 1
}

# Funktion für Erfolgsmeldungen
success_message() {
    echo -e "${GREEN}ERFOLG: $1${NC}"
}

# 1. System-Basis-Setup
echo -e "\n${YELLOW}=== 1. System-Basis-Setup ===${NC}"
./system/base_setup.sh || handle_error "System-Basis-Setup fehlgeschlagen"
success_message "System-Basis-Setup abgeschlossen"

# 2. Benutzerberechtigungen
echo -e "\n${YELLOW}=== 2. Benutzerberechtigungen Setup ===${NC}"
./system/user_permissions.sh || handle_error "Benutzerberechtigungen-Setup fehlgeschlagen"
success_message "Benutzerberechtigungen eingerichtet"

# 3. GPU-Setup
echo -e "\n${YELLOW}=== 3. GPU-Setup ===${NC}"
./gpu/tesla_p100_setup.sh || handle_error "GPU-Setup fehlgeschlagen"
success_message "GPU-Setup abgeschlossen"

# 4. CPU-Setup
echo -e "\n${YELLOW}=== 4. CPU-Setup ===${NC}"
./cpu/xeon_e5_2699_setup.sh || handle_error "CPU-Setup fehlgeschlagen"
success_message "CPU-Setup abgeschlossen"

# 5. Debug-Tools Setup
echo -e "\n${YELLOW}=== 5. Debug-Tools Setup ===${NC}"
chmod +x ./debug/service_debug.sh
success_message "Debug-Tools installiert"

# 6. Monitoring-Setup
echo -e "\n${YELLOW}=== 6. Monitoring-Setup ===${NC}"
# Monitoring-Cronjob einrichten
(crontab -l 2>/dev/null; echo "*/5 * * * * $SCRIPT_DIR/monitoring/hardware_monitor.sh") | crontab -
success_message "Monitoring eingerichtet"

# 7. Wartungs-Setup
echo -e "\n${YELLOW}=== 7. Wartungs-Setup ===${NC}"
# Täglichen Wartungs-Cronjob einrichten
(crontab -l 2>/dev/null; echo "0 3 * * * $SCRIPT_DIR/maintenance/system_maintenance.sh") | crontab -
success_message "Wartung eingerichtet"

# Systemd-Services erstellen
echo -e "\n${YELLOW}=== 8. Service-Konfiguration ===${NC}"

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
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# Service aktivieren
sudo systemctl daemon-reload
sudo systemctl enable hardware-monitoring
sudo systemctl start hardware-monitoring
success_message "Services konfiguriert"

# Abschlussprüfung
echo -e "\n${YELLOW}=== Abschlussprüfung ===${NC}"

# Debug-Check ausführen
echo "Führe Debug-Check aus..."
./debug/service_debug.sh

# Zusammenfassung
echo -e "\n${YELLOW}=== Setup-Zusammenfassung ===${NC}"
echo "1. System-Basis: Installiert und konfiguriert"
echo "2. Benutzerberechtigungen: Rootless-Setup und DB-Zugänge"
echo "3. GPU-Setup: Tesla P100 Dual-GPU konfiguriert"
echo "4. CPU-Setup: Xeon E5-2699 v3 optimiert"
echo "5. Debug-Tools: Installiert und konfiguriert"
echo "6. Monitoring: Automatisiert (alle 5 Minuten)"
echo "7. Wartung: Tägliche Wartung um 3 Uhr morgens"
echo "8. Services: Systemd-Services eingerichtet"

echo -e "\n${GREEN}=== Master-Setup Ende: $(date) ===${NC}"
echo -e "${YELLOW}Bitte führen Sie einen Systemneustart durch: 'sudo reboot'${NC}"