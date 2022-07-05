#!/bin/bash
# SSR Setup
# Edition : Stable Edition V1.0
# Auther  : AWALUDIN FERIYANTO
# (C) Copyright 2021-2022 By autosc.me
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

source /etc/os-release
if [[ $ID == "ubuntu" ]]; then
    if [[ $VERSION_ID = "18.04" ]]; then
        export OS="Ubuntu18"
    elif [[ $VERSION_ID = "20.04" ]]; then
        export OS="Ubuntu20"
    elif [[ $VERSION_ID == "20.10" ]]; then
        export OS="Ubuntu20"
    elif [[ $VERSION_ID == "21.04" ]]; then
        export OS="Ubuntu21"
    elif [[ $VERSION_ID == "21.10" ]]; then
        export OS="Ubuntu21"
    else
        export OS="Ubuntu20"
    fi
elif [[ $ID == "debian" ]]; then
    if [[ $VERSION_ID = "9" ]]; then
        export OS="Debian9"
    elif [[ $VERSION_ID = "10" ]]; then
        export OS="Debian10"
    elif [[ $VERSION_ID == "11" ]]; then
        export OS="Debian11"
    elif [[ $VERSION_ID == "12" ]]; then
        export OS="Debian12"
    else
        export OS="Debian10"
    fi
fi

# // Make SSTP Directory
rm -r -f /etc/${Auther}/SSTP-Server/
rm -r -f /root/accel-ppp/
mkdir -p /etc/${Auther}/
mkdir -p /etc/${Auther}/SSTP-Server/

# // Go To Root directory
cd /root/

# // Installing Requirement Tools
apt update -y
apt upgrade -y
apt autoremove -y
apt clean -y
apt install build-essential -y
apt install cmake -y
apt install gcc -y
apt install linux-headers-$( uname -r ) -y
apt install libpcre3-dev -y
apt install libssl-dev -y
apt install liblua5.1-0-dev -y
apt install ppp -y

# // Installing Accel-PPP Core From Make & Cmake
wget -q -O /root/accel.zip "https://${Server_URL}/accel.zip"
unzip -o accel.zip
mkdir -p /root/accel-ppp/build/
cd /root/accel-ppp/build/
cmake -DBUILD_IPOE_DRIVER=TRUE -DBUILD_VLAN_MON_DRIVER=TRUE -DCMAKE_INSTALL_PREFIX=/usr -DKDIR=/usr/src/linux-headers-`uname -r` -DLUA=TRUE -DCPACK_TYPE=$OS ..
make
cpack -G DEB
dpkg -i *.deb

# // Remove Not Used Config
rm -r -f /root/accel-ppp
rm -f /root/accel.zip
rm -f /etc/accel-ppp.conf.dist

# // Downlaoding Accel-PPP Config
wget -q -O /etc/accel-ppp.conf "https://${Server_URL}/accel.conf"
sed -i $MYIP2 /etc/accel-ppp.conf
chmod +x /etc/accel-ppp.conf

# // Downloading SSTP Certificate
cd /etc/${Auther}/SSTP-Server/
wget -q -O SSTP-Certificate.zip "https://${Server_URL}/SSTP-Certificate.zip"
unzip -o SSTP-Certificate.zip
rm -f /etc/${Auther}/SSTP-Server/SSTP-Certificate.zip
cp ca.crt /etc/${Auther}/webserver/sstp.crt

# // Make Client Folder
cat > /etc/DuniaVPN/SSTP-Server/client.db << END
#SSTP
END

# // Adding IPTables For SSTP
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 654 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 654 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null
netfilter-persistent reload > /dev/null

# // Starting Service
systemctl stop accel-ppp
systemctl enable accel-ppp
systemctl start accel-ppp
systemctl restart accel-ppp
/etc/init.d/accel-ppp restart

# // Remove Not Used Files
rm -f /root/sstp.sh
