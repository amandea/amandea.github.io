#!/bin/bash
# XRay Setup
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

# // Downloading XRay Core
wget -q -O /usr/local/${Auther}/xray-mini "https://${Server_URL}/xray-mini"
chmod +x /usr/local/${Auther}/xray-mini

# // Downloading XRay Mini Service
wget -q -O /etc/systemd/system/xray-mini@.service "https://${Server_URL}/xray-mini.service"

# // Random UUID
uuid=$( cat /proc/sys/kernel/random/uuid );

# // Removing Old Folder
rm -r -f /etc/xray-mini/
mkdir -p /etc/xray-mini/
mkdir -p /etc/${Auther}/xray-logs/

# // Downloading Configuration
wget -q -O /etc/xray-mini/vmess-tls.json "https://${Server_URL}/vmess-tls.json"
wget -q -O /etc/xray-mini/vmess-nontls.json "https://${Server_URL}/vmess-nontls.json"
wget -q -O /etc/xray-mini/trojan.json "https://${Server_URL}/trojan.json"
wget -q -O /etc/xray-mini/shadowsocks.json "https://${Server_URL}/shadowsocks.json"
wget -q -O /etc/xray-mini/vless-nontls.json "https://${Server_URL}/vless-nontls.json"
wget -q -O /etc/xray-mini/vless-tls.json "https://${Server_URL}/vless-tls.json"

# // Input UUID To Config
sed -i "s/uuidnya/${uuid}/g" /etc/xray-mini/vmess-tls.json
sed -i "s/uuidnya/${uuid}/g" /etc/xray-mini/vmess-nontls.json
sed -i "s/uuidnya/${uuid}/g" /etc/xray-mini/trojan.json
sed -i "s/uuidnya/${uuid}/g" /etc/xray-mini/shadowsocks.json
sed -i "s/uuidnya/${uuid}/g" /etc/xray-mini/vless-nontls.json
sed -i "s/uuidnya/${uuid}/g" /etc/xray-mini/vless-tls.json

# // Waktu Sekarang
waktu_sekarang=`date -d "0 days" +"%Y-%m-%d %X"`

# // Adding README Files
printf "XRay-Mini Configuration Files\n----------------------------------------\nGenerated By FSIDVPN AutoScript\nGenerated at [ ${waktu_sekarang} ]\nRequest ID   [ ${RANDOM}${RANDOM}${RANDOM}${RANDOM} ]\n----------------------------------------\n(C) Copyright 2021-2022 By DuniaVPN.Net" > /etc/xray-mini/README

# // Inout IPTables For Vmess NonTLS
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2082 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2082 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Inout IPTables For Vmess TLS
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2083 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2083 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Inout IPTables For Vless NonTLS
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2086 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2086 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Inout IPTables For Vless NonTLS
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2087 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2087 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Inout IPTables For Trojan
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8443 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Inout IPTables For ShadowSocks
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8880 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Enable Vmess NonTLS XRay
systemctl stop xray-mini@vmess-nontls > /dev/null 2>&1
systemctl disable xray-mini@vmess-nontls > /dev/null 2>&1
systemctl enable xray-mini@vmess-nontls
systemctl start xray-mini@vmess-nontls

# // Enable Vmess TLS XRay
systemctl stop xray-mini@vmess-tls > /dev/null 2>&1
systemctl disable xray-mini@vmess-tls > /dev/null 2>&1
systemctl enable xray-mini@vmess-tls
systemctl start xray-mini@vmess-tls

# // Enable Vless NonTLS XRay
systemctl stop xray-mini@vless-nontls > /dev/null 2>&1
systemctl disable xray-mini@vless-nontls > /dev/null 2>&1
systemctl enable xray-mini@vless-nontls
systemctl start xray-mini@vless-nontls

# // Enable Vless TLS XRay
systemctl stop xray-mini@vless-tls > /dev/null 2>&1
systemctl disable xray-mini@vless-tls > /dev/null 2>&1
systemctl enable xray-mini@vless-tls
systemctl start xray-mini@vless-tls

# // Enable Trojan XRay
systemctl stop xray-mini@trojan > /dev/null 2>&1
systemctl disable xray-mini@trojan > /dev/null 2>&1
systemctl enable xray-mini@trojan
systemctl start xray-mini@trojan

# // Enable Shadowsocks XRay
systemctl stop xray-mini@shadowsocks > /dev/null 2>&1
systemctl disable xray-mini@shadowsocks > /dev/null 2>&1
systemctl enable xray-mini@shadowsocks
systemctl start xray-mini@shadowsocks

# // Remove Not Used File
rm -f /root/xray.sh
