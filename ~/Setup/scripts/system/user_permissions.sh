#!/bin/bash
# Benutzerberechtigungen und Rootless-Setup

echo "=== Benutzer-Konfiguration Start ==="

# Aktueller Benutzer
CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~$CURRENT_USER)

# PostgreSQL Konfiguration
echo "Konfiguriere PostgreSQL für Benutzer..."
sudo -u postgres createuser --superuser $CURRENT_USER
sudo -u postgres createdb $CURRENT_USER

# MariaDB Konfiguration
echo "Konfiguriere MariaDB für Benutzer..."
sudo mysql -e "CREATE USER '$CURRENT_USER'@'localhost' IDENTIFIED BY '';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$CURRENT_USER'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# MongoDB Konfiguration
echo "Konfiguriere MongoDB für Benutzer..."
mongosh admin --eval "db.createUser({user: '$CURRENT_USER', pwd: '', roles: ['root']})"

# Docker Rootless Setup
echo "Konfiguriere Docker Rootless..."

# Docker-Rootless Abhängigkeiten
sudo apt-get install -y \
    uidmap \
    dbus-user-session \
    fuse-overlayfs \
    slirp4netns

# Docker-Rootless Installation
curl -fsSL https://get.docker.com/rootless | sh

# Docker-Rootless Umgebungsvariablen
cat << 'EOF' | tee -a $USER_HOME/.bashrc

# Docker Rootless Konfiguration
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
EOF

# Systemd User Service für Docker
mkdir -p $USER_HOME/.config/systemd/user
cat << EOF > $USER_HOME/.config/systemd/user/docker.service
[Unit]
Description=Docker Application Container Engine (Rootless)
Documentation=https://docs.docker.com/engine/security/rootless/

[Service]
Environment=PATH=/usr/bin:/sbin:/usr/sbin:$PATH
ExecStart=$USER_HOME/bin/dockerd-rootless.sh
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
Type=simple
KillMode=mixed

[Install]
WantedBy=default.target
EOF

# Systemd User Service aktivieren
systemctl --user enable docker
systemctl --user start docker
loginctl enable-linger $CURRENT_USER

# Debug-Tools installieren
echo "Installiere Debug-Tools..."
sudo apt-get install -y \
    strace \
    ltrace \
    gdb \
    valgrind \
    htop \
    iotop \
    nethogs \
    tcpdump \
    wireshark

# Berechtigungen für Debug-Tools
sudo usermod -aG wireshark $CURRENT_USER
sudo setcap cap_net_raw,cap_net_admin=eip $(which tcpdump)

# Datenbank-Verzeichnisse
echo "Erstelle Datenbank-Verzeichnisse..."
mkdir -p $USER_HOME/data/{postgres,mysql,mongodb}

# PostgreSQL lokale Instanz
initdb -D $USER_HOME/data/postgres
echo "port = 5435" >> $USER_HOME/data/postgres/postgresql.conf

# MariaDB lokale Instanz
mysql_install_db --datadir=$USER_HOME/data/mysql

# MongoDB lokale Instanz
mongod --dbpath $USER_HOME/data/mongodb --port 27018 --fork --logpath $USER_HOME/data/mongodb/mongodb.log

# Startup-Skript
cat << 'EOF' > $USER_HOME/start_dbs.sh
#!/bin/bash
# Datenbanken starten
pg_ctl -D ~/data/postgres -l ~/data/postgres/logfile start
mysqld --datadir=~/data/mysql --socket=/tmp/mysql.sock --pid-file=/tmp/mysql.pid &
mongod --dbpath ~/data/mongodb --port 27018 --fork --logpath ~/data/mongodb/mongodb.log
EOF

chmod +x $USER_HOME/start_dbs.sh

echo "=== Benutzer-Konfiguration abgeschlossen ==="
echo "Bitte führen Sie 'source ~/.bashrc' aus und starten Sie Ihre Sitzung neu."