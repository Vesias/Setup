#!/bin/bash
# Sicherheits-Check-Skript

# Logging
log_file="/var/log/security_check.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Sicherheits-Check gestartet: $(date) ==="

# Überprüfe offene Ports
echo "Offene Ports:"
netstat -tuln

# Überprüfe aktive Dienste
echo -e "\nAktive Dienste:"
systemctl list-units --type=service | grep running

# Überprüfe Firewall-Regeln
echo -e "\nFirewall-Regeln:"
sudo ufw status

# Überprüfe zuletzt angemeldete Benutzer
echo -e "\nLetzte Anmeldungen:"
last -a | head -n 10

# Überprüfe sudo-Aktivitäten
echo -e "\nSudo-Aktivitäten:"
sudo journalctl -u sudo | grep COMMAND | tail -n 10

# Suche nach potenziell unsicheren Dateiberechtigungen
echo -e "\nDateien mit unsicheren Berechtigungen:"
find / -type f \( -perm -004 -o -perm -002 \) -ls 2>/dev/null | head -n 20

echo "=== Sicherheits-Check abgeschlossen: $(date) ==="
