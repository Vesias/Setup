# Datenbank Zugangsdaten

## PostgreSQL
- Host: localhost
- Port: 5432
- Admin User: postgres
- Password: Secure_PG_Pass123

## MariaDB
- Host: localhost
- Port: 3306
- Root Password: [Gesetzt via mysql_secure_installation]

## MongoDB
- Host: localhost
- Port: 27017
- Admin User: admin
- Password: Secure_Mongo_Pass123

## Netdata
- URL: http://localhost:19999

# Wichtige Verzeichnisse
- Datenbank-Daten: /mnt/data/databases/
- Backups: /mnt/data/backups/
- Docker-Daten: /mnt/data/docker/
- Projekt-Daten: /mnt/data/projects/

# Wartung
- Backup-Skript: ~/maintenance.sh
- Monitoring-Skript: ~/monitor_alert.sh
- System-Logs: /var/log/system_maintenance/

# Cron-Jobs
0 3 * * * /home/xuf1337/maintenance.sh
*/5 * * * * /home/xuf1337/monitor_alert.sh

# Aktive Ports
Netid State  Recv-Q Send-Q                      Local Address:Port  Peer Address:PortProcess                                                                                                 
udp   UNCONN 0      0                              127.0.0.54:53         0.0.0.0:*    users:(("systemd-resolve",pid=18534,fd=16))                                                            
udp   UNCONN 0      0                           127.0.0.53%lo:53         0.0.0.0:*    users:(("systemd-resolve",pid=18534,fd=14))                                                            
udp   UNCONN 0      0                   192.168.178.20%enp4s0:68         0.0.0.0:*    users:(("systemd-network",pid=18548,fd=22))                                                            
udp   UNCONN 0      0                               127.0.0.1:8125       0.0.0.0:*    users:(("python.d.plugin",pid=42959,fd=48),("apps.plugin",pid=42958,fd=48),("netdata",pid=42547,fd=48))
udp   UNCONN 0      0      [fe80::e2d5:5eff:fe51:1171]%enp4s0:546           [::]:*    users:(("systemd-network",pid=18548,fd=23))                                                            
tcp   LISTEN 0      4096                            127.0.0.1:8125       0.0.0.0:*    users:(("python.d.plugin",pid=42959,fd=50),("apps.plugin",pid=42958,fd=50),("netdata",pid=42547,fd=50))
tcp   LISTEN 0      80                              127.0.0.1:3306       0.0.0.0:*    users:(("mariadbd",pid=31775,fd=22))                                                                   
tcp   LISTEN 0      4096                        127.0.0.53%lo:53         0.0.0.0:*    users:(("systemd-resolve",pid=18534,fd=15))                                                            
tcp   LISTEN 0      4096                            127.0.0.1:19999      0.0.0.0:*    users:(("netdata",pid=42547,fd=6))                                                                     
tcp   LISTEN 0      1024                            127.0.0.1:42377      0.0.0.0:*    users:(("code-cd4ee3b1c3",pid=3410,fd=9))                                                              
tcp   LISTEN 0      4096                           127.0.0.54:53         0.0.0.0:*    users:(("systemd-resolve",pid=18534,fd=17))                                                            
tcp   LISTEN 0      4096                                    *:22               *:*    users:(("sshd",pid=18519,fd=3),("systemd",pid=1,fd=92))                                                
