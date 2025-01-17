#!/bin/bash
# Netzwerk-Diagnose-Skript

# Logging
log_file="/var/log/network_diagnostics.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Netzwerk-Diagnose gestartet: $(date) ==="

# Netzwerk-Schnittstellen
echo "Netzwerk-Schnittstellen:"
ip addr show

# Routing-Tabelle
echo -e "\nRouting-Tabelle:"
ip route

# DNS-Konfiguration
echo -e "\nDNS-Konfiguration:"
cat /etc/resolv.conf

# Verbindungstest
echo -e "\nVerbindungstest:"
ping -c 4 8.8.8.8
ping -c 4 google.com

# Offene Ports
echo -e "\nOffene Ports:"
ss -tuln

echo "=== Netzwerk-Diagnose abgeschlossen: $(date) ==="
