#!/bin/bash
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
# Link Hosting Kalian
akbarvpn="raw.githubusercontent.com/fsidvpn/scriptvps/main/backup"

apt install rclone -y >/dev/null 2>&1
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://${akbarvpn}/rclone.conf" >/dev/null 2>&1
git clone  https://github.com/magnific0/wondershaper.git >/dev/null 2>&1
cd wondershaper
make install >/dev/null 2>&1
cd
rm -rf wondershaper >/dev/null 2>&1
echo > /home/limit
apt install msmtp-mta ca-certificates bsd-mailx -y >/dev/null 2>&1
cat<<EOF>>/etc/msmtprc
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host smtp.gmail.com
port 587
auth on
user bckupvpns@gmail.com
from bckupvpns@gmail.com
password Yangbaru1 
logfile ~/.msmtp.log
EOF
chown -R www-data:www-data /etc/msmtprc
cd /usr/bin
wget -O autobackup "https://${akbarvpn}/autobackup.sh" >/dev/null 2>&1
wget -O backup "https://${akbarvpn}/backup.sh" >/dev/null 2>&1
wget -O restore "https://${akbarvpn}/restore.sh" >/dev/null 2>&1
wget -O strt "https://${akbarvpn}/strt.sh" >/dev/null 2>&1
wget -O limitspeed "https://${akbarvpn}/limitspeed.sh" >/dev/null 2>&1
chmod +x autobackup >/dev/null 2>&1
chmod +x backup >/dev/null 2>&1
chmod +x restore >/dev/null 2>&1
chmod +x strt >/dev/null 2>&1
chmod +x limitspeed >/dev/null 2>&1
cd
rm -f /root/set-br.sh >/dev/null 2>&1
