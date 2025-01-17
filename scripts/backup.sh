#!/bin/bash
# Umfassendes Backup-Skript

# Konfigurationen
BACKUP_DIR="/mnt/data/backups/$(date '+%Y-%m-%d_%H-%M-%S')"
DIRS_TO_BACKUP=(
    "/home/$USER/Documents"
    "/home/$USER/Projects"
    "/etc"
)

# Logging
log_file="/var/log/system_backup.log"
exec > >(tee -a "$log_file") 2>&1

echo "=== Backup gestartet: $(date) ==="

# Backup-Verzeichnis erstellen
mkdir -p "$BACKUP_DIR"

# Verzeichnisse sichern
for dir in "${DIRS_TO_BACKUP[@]}"; do
    if [ -d "$dir" ]; then
        tar -czvf "$BACKUP_DIR/$(basename "$dir")_backup.tar.gz" "$dir"
        echo "Backup von $dir abgeschlossen"
    fi
done

# Datenbank-Backups
pg_dumpall > "$BACKUP_DIR/postgresql_backup.sql"
mysqldump --all-databases > "$BACKUP_DIR/mariadb_backup.sql"
mongodump --out "$BACKUP_DIR/mongodb_backup"

# Alte Backups löschen (älter als 30 Tage)
find /mnt/data/backups -type d -mtime +30 -exec rm -rf {} \;

echo "=== Backup abgeschlossen: $(date) ==="
