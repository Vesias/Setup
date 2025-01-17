#!/bin/bash

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== Server Setup Script ===${NC}"

# System Update
echo -e "${GREEN}Updating system...${NC}"
sudo apt update && sudo apt upgrade -y

# Basic Tools
echo -e "${GREEN}Installing basic tools...${NC}"
sudo apt install -y nala cmus sl gdebi wget curl software-properties-common build-essential

# Development Tools
echo -e "${GREEN}Installing development tools...${NC}"
# Python
sudo apt install -y python3-pip python3-venv
python3 -m pip install --user pipx
python3 -m pipx ensurepath
python3 -m pipx install poetry

# Node.js via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Databases
echo -e "${GREEN}Installing databases...${NC}"
# PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

# MariaDB
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable mariadb
sudo systemctl start mariadb

# MongoDB
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl enable mongod
sudo systemctl start mongod

# ML und CUDA
echo -e "${GREEN}Installing ML tools and CUDA...${NC}"
sudo apt install -y nvidia-cuda-toolkit nvidia-cudnn

# Python ML libraries
python3 -m pip install --user numpy pandas scikit-learn tensorflow torch solana web3 jupyter

# Solana
sh -c "$(curl -sSfL https://release.solana.com/v1.17.16/install)"

# Disk Setup
echo -e "${GREEN}Setting up disks...${NC}"
# Identifiziere nicht gemountete Festplatten
DISKS=$(lsblk -r -o NAME,MOUNTPOINT | awk '$2 == "" && length($1) == 3 {print $1}')

if [ -n "$DISKS" ]; then
    echo -e "${GREEN}Found unmounted disks: $DISKS${NC}"
    for DISK in $DISKS; do
        echo -e "${GREEN}Processing /dev/$DISK...${NC}"
        # Erstelle eine neue Partition
        sudo parted /dev/$DISK mklabel gpt
        sudo parted -a opt /dev/$DISK mkpart primary ext4 0% 100%
        
        # Formatiere die Partition
        sudo mkfs.ext4 /dev/${DISK}1
        
        # Erstelle Mount-Punkt
        sudo mkdir -p /mnt/data_${DISK}
        
        # Füge zum fstab hinzu
        echo "/dev/${DISK}1 /mnt/data_${DISK} ext4 defaults 0 2" | sudo tee -a /etc/fstab
        
        # Mounte die Partition
        sudo mount /dev/${DISK}1 /mnt/data_${DISK}
    done
fi

# Environment Setup
echo -e "${GREEN}Setting up environment...${NC}"
# Python virtuelle Umgebung
mkdir -p ~/projects/solana_trading
cd ~/projects/solana_trading
python3 -m venv venv
echo "source ~/projects/solana_trading/venv/bin/activate" >> ~/.bashrc

# CUDA Konfiguration
echo 'export PATH="/usr/local/cuda/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc

# Jupyter Konfiguration
mkdir -p ~/.jupyter
cat > ~/.jupyter/jupyter_config.py << EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
EOF

# Firewall Setup
echo -e "${GREEN}Configuring firewall...${NC}"
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable

echo -e "${GREEN}Setup completed!${NC}"

# 24/7 Optimierungen
echo -e "${GREEN}Configuring 24/7 optimizations...${NC}"

# Automatische Updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Monitoring Tools
sudo apt install -y htop iotop sysstat netdata

# Logrotation
sudo tee /etc/logrotate.d/custom_logs << EOF
/var/log/syslog
/var/log/kern.log
/var/log/auth.log
{
    rotate 7
    daily
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
EOF

# Journal Konfiguration
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo tee /etc/systemd/journald.conf.d/00-journal-size.conf << EOF
[Journal]
SystemMaxUse=1G
SystemMaxFileSize=100M
EOF

# System Tuning
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Monitoring Service
sudo tee /etc/systemd/system/system-monitor.service << EOF
[Unit]
Description=System Monitoring Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/vmstat 300
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

# Aktiviere Services
sudo systemctl daemon-reload
sudo systemctl enable system-monitor
sudo systemctl start system-monitor
sudo systemctl enable netdata
sudo systemctl start netdata

# Firewall-Regel für Netdata
sudo ufw allow 19999/tcp

echo -e "${GREEN}24/7 optimizations completed!${NC}"
echo -e "${GREEN}Netdata monitoring available at: http://localhost:19999${NC}"

# Optimierte Festplatten-Konfiguration
echo -e "${GREEN}Konfiguriere Festplatten...${NC}"

# LVM erweitern
pvcreate /dev/sda3
vgextend ubuntu-vg /dev/sda3
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
resize2fs /dev/ubuntu-vg/ubuntu-lv

# Datenpartition einrichten
mkdir -p /mnt/data
mkfs.ext4 -F /dev/sdb2
mount /dev/sdb2 /mnt/data

# Verzeichnisstruktur erstellen
mkdir -p /mnt/data/{backups,docker,databases,projects}
chown -R $USER:$USER /mnt/data

# fstab Eintrag
echo "UUID=$(blkid -s UUID -o value /dev/sdb2) /mnt/data ext4 defaults,nofail 0 2" >> /etc/fstab

# Datenbanken auf neue Festplatte migrieren
systemctl stop postgresql mariadb mongod

# PostgreSQL
mv /var/lib/postgresql /mnt/data/databases/
ln -s /mnt/data/databases/postgresql /var/lib/postgresql
chown -R postgres:postgres /mnt/data/databases/postgresql

# MariaDB
mv /var/lib/mysql /mnt/data/databases/
ln -s /mnt/data/databases/mysql /var/lib/mysql
chown -R mysql:mysql /mnt/data/databases/mysql

# MongoDB
mv /var/lib/mongodb /mnt/data/databases/
ln -s /mnt/data/databases/mongodb /var/lib/mongodb
chown -R mongodb:mongodb /mnt/data/databases/mongodb

# Docker Konfiguration
mkdir -p /mnt/data/docker
echo '{
    "data-root": "/mnt/data/docker"
}' > /etc/docker/daemon.json

# Dienste neustarten
systemctl restart postgresql mariadb mongod docker

echo -e "${GREEN}Festplatten-Konfiguration abgeschlossen${NC}"
