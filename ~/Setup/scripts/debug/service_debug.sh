#!/bin/bash
# Debug-Skript für Dienste und Datenbanken

echo "=== Debug-Analyse Start: $(date) ==="

# Logging
log_file="$HOME/service_debug.log"
exec > >(tee -a "$log_file") 2>&1

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Hilfsfunktion für Status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} $1"
    else
        echo -e "${RED}[FEHLER]${NC} $1"
    fi
}

# PostgreSQL Debug
echo -e "\n${YELLOW}=== PostgreSQL Debug ===${NC}"
echo "1. Benutzer-Instanz Status:"
pg_ctl -D ~/data/postgres status
print_status "PostgreSQL Status"

echo "2. PostgreSQL Ports:"
netstat -tuln | grep 5432
netstat -tuln | grep 5435
print_status "PostgreSQL Ports"

echo "3. PostgreSQL Logs:"
tail -n 20 ~/data/postgres/logfile

# MariaDB Debug
echo -e "\n${YELLOW}=== MariaDB Debug ===${NC}"
echo "1. Benutzer-Instanz Status:"
if [ -f /tmp/mysql.pid ]; then
    echo "MariaDB läuft (PID: $(cat /tmp/mysql.pid))"
else
    echo "MariaDB nicht aktiv"
fi
print_status "MariaDB Status"

echo "2. MariaDB Socket:"
ls -l /tmp/mysql.sock
print_status "MariaDB Socket"

echo "3. MariaDB Logs:"
tail -n 20 ~/data/mysql/*.err

# MongoDB Debug
echo -e "\n${YELLOW}=== MongoDB Debug ===${NC}"
echo "1. Benutzer-Instanz Status:"
pgrep -f "mongod --dbpath ~/data/mongodb"
print_status "MongoDB Status"

echo "2. MongoDB Ports:"
netstat -tuln | grep 27017
netstat -tuln | grep 27018
print_status "MongoDB Ports"

echo "3. MongoDB Logs:"
tail -n 20 ~/data/mongodb/mongodb.log

# Docker Rootless Debug
echo -e "\n${YELLOW}=== Docker Rootless Debug ===${NC}"
echo "1. Docker Status:"
systemctl --user status docker
print_status "Docker Status"

echo "2. Docker Socket:"
ls -l $XDG_RUNTIME_DIR/docker.sock
print_status "Docker Socket"

echo "3. Docker Info:"
docker info
print_status "Docker Info"

echo "4. Docker Netzwerk:"
docker network ls
print_status "Docker Netzwerk"

# Berechtigungen Debug
echo -e "\n${YELLOW}=== Berechtigungen Debug ===${NC}"
echo "1. Benutzergruppen:"
groups
print_status "Benutzergruppen"

echo "2. Datenbank-Verzeichnisse:"
ls -la ~/data/
print_status "Datenbank-Verzeichnisse"

echo "3. Socket-Verzeichnisse:"
ls -la /tmp/mysql.sock /tmp/.s.PGSQL.*
print_status "Socket-Verzeichnisse"

# Ressourcen-Debug
echo -e "\n${YELLOW}=== Ressourcen Debug ===${NC}"
echo "1. Speichernutzung:"
free -h
print_status "Speichernutzung"

echo "2. Festplattennutzung:"
df -h ~/data
print_status "Festplattennutzung"

echo "3. Offene Ports:"
netstat -tuln
print_status "Offene Ports"

# Reparaturvorschläge
echo -e "\n${YELLOW}=== Reparaturvorschläge ===${NC}"
# PostgreSQL
if ! pg_ctl -D ~/data/postgres status >/dev/null 2>&1; then
    echo "PostgreSQL: pg_ctl -D ~/data/postgres start"
fi

# MariaDB
if [ ! -f /tmp/mysql.pid ]; then
    echo "MariaDB: mysqld --datadir=~/data/mysql --socket=/tmp/mysql.sock --pid-file=/tmp/mysql.pid"
fi

# MongoDB
if ! pgrep -f "mongod --dbpath ~/data/mongodb" >/dev/null; then
    echo "MongoDB: mongod --dbpath ~/data/mongodb --port 27018 --fork --logpath ~/data/mongodb/mongodb.log"
fi

# Docker
if ! systemctl --user is-active docker >/dev/null 2>&1; then
    echo "Docker: systemctl --user start docker"
fi

echo -e "\n=== Debug-Analyse Ende: $(date) ==="