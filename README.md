# Homeserver Setup-Dokumentation

## System-Übersicht
- OS: Ubuntu 24.04 LTS
- RAM: 128GB
- Swap: 8GB
- Hauptspeicher: 98GB (LVM)
- Zusatzspeicher: /mnt/data

## Installierte Dienste
1. Datenbanken
   - PostgreSQL
   - MariaDB
   - MongoDB

2. Entwicklungsumgebung
   - Python 3.12.3
   - CUDA 12.0
   - Solana CLI
   - Node.js (via NVM)

3. Monitoring
   - Netdata (http://localhost:19999)
   - System Monitor Service
   - Custom Monitoring Scripts

## Automatische Wartung
- Tägliches Backup (3:00 Uhr)
- 5-Minütliche System-Checks
- Log-Rotation
- Automatische Updates

## Wartungsskripte
1. `/home/xuf1337/maintenance.sh`
   - Tägliche Systemwartung
   - Datenbank-Backups
   - Service-Überprüfung

2. `/home/xuf1337/monitor_alert.sh`
   - System-Ressourcen Monitoring
   - Warnungen bei Grenzwertüberschreitung

## Backup-Strategie
- Tägliche Datenbank-Backups
- 7-Tage Aufbewahrung
- Speicherort: /mnt/data/backups/

## Monitoring-Schwellenwerte
- Festplattennutzung: 90%
- RAM-Nutzung: 90%
- System-Load: 10

## Wichtige Verzeichnisse
- Logs: `/var/log/system_maintenance.log`
- Backups: `/mnt/data/backups/`
- Projekte: `~/projects/`

## Sicherheit
- Automatische Updates aktiviert
- Firewall konfiguriert
- Fail2ban installiert

## Trading-Setup
- Solana Trading Environment in `~/projects/solana_trading/`
- Python venv aktiviert
- CUDA für ML-Workloads konfiguriert

## Wartungshinweise
1. Regelmäßige Überprüfungen
   - Netdata Dashboard
   - System-Logs
   - Backup-Integrität

2. Manuelle Wartung
   - Überprüfung der Backups
   - Aktualisierung der Monitoring-Schwellenwerte
   - Bereinigung alter Logs

## Support
Bei Problemen:
1. Prüfe die Logs in `/var/log/`
2. Überprüfe den Service-Status mit `systemctl status <service>`
3. Kontrolliere das Netdata Dashboard

## Festplatten-Layout
1. Systemplatte (sda):
   - sda1: 1M (Reserved)
   - sda2: 2G (/boot)
   - sda3: 1.8T (LVM)

2. Datenplatte (sdb):
   - sdb1: 1G (Reserved)
   - sdb2: 930G (/mnt/data)
      - /mnt/data/backups
      - /mnt/data/docker
      - /mnt/data/databases
      - /mnt/data/projects

## Datenbankpfade
- PostgreSQL: /mnt/data/databases/postgresql
- MariaDB: /mnt/data/databases/mysql
- MongoDB: /mnt/data/databases/mongodb
- Docker: /mnt/data/docker

## Performance-Optimierungen
- Datenbanken auf separater Festplatte
- LVM für flexibles Storage-Management
- Optimierte Mount-Optionen
- Automatische Backup-Rotation

## Datenbank-Migration
- Alle Datenbanken wurden auf /mnt/data/databases/ migriert
- Symbolische Links in Standardverzeichnissen beibehalten
- Volle Datensicherheit und Performance-Optimierung

### Datenbank-Pfade
- PostgreSQL: /mnt/data/databases/postgresql
- MariaDB: /mnt/data/databases/mysql
- MongoDB: /mnt/data/databases/mongodb

### Migration Vorteile
- Separate Speicherung von Systemdaten
- Einfachere Backup-Strategien
- Verbesserte I/O-Performance
- Flexiblere Speicherverwaltung

## Machine Learning Entwicklungsumgebung
- Python ML-Bibliotheken installiert
  * PyTorch
  * TensorFlow
  * Keras
  * NumPy, Pandas
  * Scikit-Learn
- CUDA-Beispielprojekt zur Überprüfung
- GPU-beschleunigte Berechnungen

### Entwicklungsumgebung Details
- Standort: ~/cuda_test
- Beispielprojekt: Vektor-Addition mit CUDA
