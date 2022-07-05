#!/bin/bash
# SSH & SSLH Setup
# Edition : Stable Edition V1.0
# Auther  : AWALUDIN FERIYANTO
# (C) Copyright 2021-2022 By FSIDVPN
# =========================================

# // Exporting Language to UTF-8
export LC_ALL='en_US.UTF-8' >/dev/null 2>&1
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export LC_CTYPE='en_US.utf8'

# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

# // Export Banner Status Information
export EROR="[${RED} EROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"

# // Export Align
export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"

# // Exporting URL Host
export Server_URL="autosc.me"
export Server_Port="443"
export Server_IP="underfined"
export Script_Mode="Stable"
export Auther="DuniaVPN"

# // Root Checking
if [ "${EUID}" -ne 0 ]; then
		echo -e "${EROR} Please Run This Script As Root User !"
		exit 1
fi

# // Exporting IP Address
export IP=$( curl -s https://api.duniavpn.net/ip/ )

# // Exporting Network Interface
export NETWORK_IFACE="$(ip route show to default | awk '{print $5}')"

# // Validate Result ( 1 )
touch /etc/${Auther}/license.key
export Your_License_Key="$( cat /etc/${Auther}/license.key | awk '{print $1}' )"
export Validated_Your_License_Key_With_Server="$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $Your_License_Key | head -n1 | cut -d ' ' -f 1 )"
if [[ "$Validated_Your_License_Key_With_Server" == "$Your_License_Key" ]]; then
    validated='true'
else
    echo -e "${EROR} License Key Not Valid"
    exit 1
fi

# // Checking VPS Status > Got Banned / No
if [[ $IP == "$( curl -s https://${Server_URL}/blacklist.txt | cut -d ' ' -f 1 | grep -w $IP | head -n1 )" ]]; then
    echo -e "${EROR} 403 Forbidden ( Your VPS Has Been Banned )"
    exit  1
fi

# // Checking VPS Status > Got Banned / No
if [[ $Your_License_Key == "$( curl -s https://${Server_URL} | cut -d ' ' -f 1 | grep -w $Your_License_Key | head -n1)" ]]; then
    echo -e "${EROR} 403 Forbidden ( Your License Has Been Limited )"
    exit  1
fi

# // Checking VPS Status > Got Banned / No
if [[ 'Standart' == "$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $Your_License_Key | head -n1 | cut -d ' ' -f 8 )" ]]; then 
    License_Mode='Standart'
elif [[ Pro == "$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $Your_License_Key | head -n1 | cut -d ' ' -f 8 )" ]]; then 
    License_Mode='Pro'
else
    echo -e "${EROR} Please Using Genuine License !"
    exit 1
fi

# // Checking Script Expired
exp=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $Your_License_Key | cut -d ' ' -f 4 )
now=`date -d "0 days" +"%Y-%m-%d"`
expired_date=$(date -d "$exp" +%s)
now_date=$(date -d "$now" +%s)
sisa_hari=$(( ($expired_date - $now_date) / 86400 ))
if [[ $sisa_hari -lt 0 ]]; then
    echo $sisa_hari > /etc/${Auther}/license-remaining-active-days.db
    echo -e "${EROR} Your License Key Expired ( $sisa_hari Days )"
    exit 1
else
    echo $sisa_hari > /etc/${Auther}/license-remaining-active-days.db
fi

# // Take VPS IP & Network Interface
MYIP2="s/xxxxxxxxx/$IP/g"
NET=$(ip route show default | awk '{print $5}')

# // Clear
clear
clear && clear && clear
clear;clear;clear

# // Installing Update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt remove --purge ufw firewalld exim4 -y # // >> Removing UFW & Firewalid Untuk Mengecah Bentrok Port Pada Firewall
apt autoremove -y
apt clean -y

# // Install Requirement Tools
apt install python -y
apt install make -y
apt install cmake -y
apt install coreutils -y
apt install rsyslog -y
apt install net-tools -y
apt install zip -y
apt install unzip -y
apt install nano -y
apt install sed -y
apt install gnupg -y
apt install gnupg1 -y
apt install bc -y
apt install jq -y
apt install apt-transport-https -y
apt install build-essential -y
apt install dirmngr -y
apt install libxml-parser-perl -y
apt install neofetch -y
apt install git -y
apt install lsof -y
apt install libsqlite3-dev -y
apt install libz-dev -y
apt install gcc -y
apt install g++ -y
apt install libreadline-dev -y
apt install zlib1g-dev -y
apt install libssl-dev -y
apt install libssl1.0-dev -y

# // Installing Password Common
wget -q -O /etc/pam.d/common-password "https://${Server_URL}/password"
chmod +x /etc/pam.d/common-password

# // Install Nginx Web Server
apt install nginx -y
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf "https://${Server_URL}/nginx.conf"
mkdir -p /etc/${Auther}/webserver/
chmod 775 /etc/${Auther}}/webserver/
wget -q -O /etc/nginx/conf.d/duniavpn.conf "https://${Server_URL}/duniavpn.conf"
wget -q -O /etc/${Auther}/webserver/index.html "https://${Server_URL}/webserver_template.txt"
/etc/init.d/nginx restart

# // Installing Squid Proxy
apt install squid -y
wget -q -O /etc/squid/squid.conf "https://${Server_URL}/squid.conf"
sed -i $MYIP2 /etc/squid/squid.conf
mkdir -p /etc/${Auther}/squid
/etc/init.d/squid restart

# // Installing Vnstat Network Monitoring
apt install vnstat -y
/etc/init.d/vnstat stop
wget -q -O vnstat.zip "https://${Server_URL}/vnstat.zip"
unzip -o vnstat.zip > /dev/null 2>&1
cd vnstat
chmod +x configure
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl disable vnstat
systemctl enable vnstat
systemctl restart vnstat
/etc/init.d/vnstat restart
rm -r -f vnstat
rm -f vnstat.zip

# // SSHD Config Template Download && Login Banner 
wget -q -O /etc/ssh/sshd_config "https://${Server_URL}/sshd"
wget -q -O /etc/${Auther}/banner.txt "https://${Server_URL}/mdx/ssh/issue.net"
chmod +x /etc/${Auther}/banner.txt

# // Installing Dropbear
apt install dropbear -y
wget -q -O /etc/default/dropbear "https://${Server_URL}/dropbear.conf"
chmod +x /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

# // Installing Stunnel5
if [[ -f /etc/systemd/system/stunnel5.service ]]; then
    systemctl disable stunnel5 > /dev/null 2>&1
    systemctl stop stunnel5 > /dev/null 2>&1
    /etc/init.d/stunnel5 stop > /dev/null 2>&1
fi
cd /root/
wget -q -O stunnel5.zip "https://${Server_URL}/stunnel5.zip"
unzip -o stunnel5.zip > /dev/null 2>&1
cd stunnel
chmod +x configure
./configure
make
make install
cd /root
rm -r -f stunnel
rm -f stunnel5.zip
mkdir -p /etc/stunnel5
chmod 644 /etc/stunnel5
wget -q -O /etc/stunnel5/stunnel5.conf "https://${Server_URL}/stunnel5.conf"
wget -q -O /etc/stunnel5/stunnel5.pem "https://${Server_URL}/Stunnel-Certificate.pem"
wget -q -O /etc/systemd/system/stunnel5.service "https://${Server_URL}/stunnel5.service"
wget -q -O /etc/init.d/stunnel5 "https://${Server_URL}/stunnel5.init"
chmod 600 /etc/stunnel5/stunnel5.pem
chmod +x /etc/init.d/stunnel5
cp /usr/local/bin/stunnel /usr/local/${Auther}/stunnel5
rm -r -f /usr/local/share/doc/stunnel/
rm -r -f /usr/local/etc/stunnel/
rm -f /usr/local/bin/stunnel
rm -f /usr/local/bin/stunnel3
rm -f /usr/local/bin/stunnel4
rm -f /usr/local/bin/stunnel5
systemctl enable stunnel5
systemctl start stunnel5
/etc/init.d/stunnel5 restart

# // Installing Fail2Ban
apt install fail2ban -y
/etc/init.d/fail2ban restart

# // Installing ePro WebSocket Proxy
wget -q -O /usr/local/${Auther}/ws-epro "https://${Server_URL}/ws-epro"
chmod +x /usr/local/${Auther}/ws-epro
wget -q -O /etc/${Auther}/ws-epro.conf "https://${Server_URL}/ws-epro.conf"
chmod 644 /etc/${Auther}/ws-epro.conf
wget -q -O /etc/systemd/system/ws-epro.service "https://${Server_URL}/ws-epro.service"
systemctl disable ws-epro > /dev/null 2>&1
systemctl stop ws-epro > /dev/null 2>&1
systemctl enable ws-epro
systemctl start ws-epro

# // Installing SSLH Server
apt install sslh -y
wget -q -O /lib/systemd/system/sslh.service "https://${Server_URL}/sslh.service"
systemctl disable sslh > /dev/null 2>&1
systemctl stop sslh > /dev/null 2>&1
systemctl enable sslh
systemctl start sslh

# // Installing UDP Mini
wget -q -O /usr/local/${Auther}/udp-mini "https://${Server_URL}/udp-mini"
chmod +x /usr/local/${Auther}/udp-mini
wget -q -O /etc/systemd/system/udp-mini-1.service "https://${Server_URL}/udp-mini-1.service"
wget -q -O /etc/systemd/system/udp-mini-2.service "https://${Server_URL}/udp-mini-2.service"
wget -q -O /etc/systemd/system/udp-mini-3.service "https://${Server_URL}/udp-mini-3.service"
systemctl disable udp-mini-1 > /dev/null 2>&1
systemctl stop udp-mini-1 > /dev/null 2>&1
systemctl enable udp-mini-1
systemctl start udp-mini-1
systemctl disable udp-mini-2 > /dev/null 2>&1
systemctl stop udp-mini-2 > /dev/null 2>&1
systemctl enable udp-mini-2
systemctl start udp-mini-2
systemctl disable udp-mini-3 > /dev/null 2>&1
systemctl stop udp-mini-3 > /dev/null 2>&1
systemctl enable udp-mini-3
systemctl start udp-mini-3

# // Installing OHP Mini
wget -q -O /usr/local/${Auther}/ohp-mini "https://${Server_URL}/ohp-mini"
chmod +x /usr/local/${Auther}/ohp-mini
wget -q -O /etc/systemd/system/ohp-mini-1.service "https://${Server_URL}/ohp-mini-1.service"
wget -q -O /etc/systemd/system/ohp-mini-2.service "https://${Server_URL}/ohp-mini-2.service"
wget -q -O /etc/systemd/system/ohp-mini-3.service "https://${Server_URL}/ohp-mini-3.service"
wget -q -O /etc/systemd/system/ohp-mini-4.service "https://${Server_URL}/ohp-mini-4.service"
systemctl disable ohp-mini-1 > /dev/null 2>&1
systemctl stop ohp-mini-1 > /dev/null 2>&1
systemctl enable ohp-mini-1
systemctl start ohp-mini-1
systemctl disable ohp-mini-2 > /dev/null 2>&1
systemctl stop ohp-mini-2 > /dev/null 2>&1
systemctl enable ohp-mini-2
systemctl start ohp-mini-2
systemctl disable ohp-mini-3 > /dev/null 2>&1
systemctl stop ohp-mini-3 > /dev/null 2>&1
systemctl enable ohp-mini-3
systemctl start ohp-mini-3
systemctl disable ohp-mini-4 > /dev/null 2>&1
systemctl stop ohp-mini-4 > /dev/null 2>&1
systemctl enable ohp-mini-4
systemctl start ohp-mini-4

# // Adding Port To IPTables ( OHP 1 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8088 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8088 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( OHP 2 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8089 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8089 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( OHP 3 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8090 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8090 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( OHP 4 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8091 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8091 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( WebSocket & SSL 443 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Dropbear WebSocket 80 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( OpenSSH 22 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 22 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Dropbear 110 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 110 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 110 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Dropbear 143 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 143 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 143 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Dropbear 990 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 990 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 990 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Dropbear 777 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 777 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 777 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Squid Proxy 8080 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8080 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Squid Proxy 8000 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8000 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Adding Port To IPTables ( Squid Proxy 3128 )
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 3128 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 3128 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Remove Not Used File
rm -f /root/ssh-ssl.sh
