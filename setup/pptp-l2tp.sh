#!/bin/bash
# PPTP L2TP Setup
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

# // String For IPSEC
export IPSec_Key='vpn'

# // Make Cache Folder
mkdir -p /run/pluto

# // Installing Requirement
apt install openssl -y
apt install libnss3-dev -y
apt install libnspr4-dev -y
apt install pkg-config -y
apt install libpam0g-dev -y
apt install libcap-ng-dev -y
apt install libcap-ng-utils -y
apt install libselinux1-dev -y
apt install libcurl4-nss-dev -y
apt install flex -y
apt install bison -y
apt install gcc -y
apt install make -y
apt install libnss3-tools -y
apt install libevent-dev -y
apt install jq -y
apt install python -y
apt install ppp -y
apt install xl2tpd -y
apt install pptpd -y
apt install libsystemd-dev -y

# // Downloading Libreswan
rm -r -f /root/Libreswan
wget -q -O /root/Libreswan.zip "https://${Server_URL}/Libreswan.zip"
unzip -o /root/Libreswan.zip
rm -f /root/Libreswan.zip
chmod +x -R /root/Libreswan

# // Making Makefile for Libreswan
cd /root/Libreswan
cat > Makefile.inc.local << END
WERROR_CFLAGS = -w
USE_DNSSEC = false
USE_DH2 = true
USE_DH31 = false
USE_NSS_AVA_COPY = true
USE_NSS_IPSEC_PROFILE = false
USE_GLIBC_KERN_FLIP_HEADERS = true
USE_XFRM_INTERFACE_IFLA_HEADER = true
END

# // Installing Libreswan Base
make -s base # >> Making Base For IPSec
make -s install-base # >> Installing The Base Of IPSec

# // Remove Libreswan Cache Folder
rm -r -f /root/Libreswan

# // Back to root Directory
cd /root/

# // L2TP Network Configuration
export L2TP_GATEWAY="10.10.13.0/24" # >> Using /24 Gateway as L2TPD Gateway
export L2TP_LOCAL="10.10.13.1" # >> Default Gateway / Server Lokal Gateway
export L2TP_DHCP_POOL="10.10.13.2-10.10.13.225" # >> DHCP Pool on 2-225

# // AUTH Network Configuration
export IPSEC_GATEWAY="10.10.14.0/24" # >> Using /24 Gateway as IPSec Authentification Gateway
export IPSEC_DHCP_POOL="10.10.14.2-10.10.14.225" # >> DHCP Pool on 10-225

# // PPTP Network Configuration
export PPTP_GATEWAY="10.10.15.1" # >> Using Default Local IP as PPTP Authentification
export PPTP_DHCP_POOL="10.10.15.2-225" # >>  DHCP Pool on 10-225

# // Configure DNS Server
export DNS_SERVER_1="8.8.8.8"
export DNS_SERVER_2="8.8.4.4"
export DNS_SERVER="\"${DNS_SERVER_1} ${DNS_SERVER_2}\""

# // Create IPSec Config File
cat > /etc/ipsec.conf <<EOF
version 2.0

config setup
  virtual-private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:!$L2TP_GATEWAY,%v4:!$IPSEC_GATEWAY
  protostack=netkey
  interfaces=%defaultroute
  uniqueids=no

conn shared
  left=%defaultroute
  leftid=$IP
  right=%any
  encapsulation=yes
  authby=secret
  pfs=no
  rekey=no
  keyingtries=5
  dpddelay=30
  dpdtimeout=120
  dpdaction=clear
  ikev2=never
  ike=aes256-sha2,aes128-sha2,aes256-sha1,aes128-sha1,aes256-sha2;modp1024,aes128-sha1;modp1024
  phase2alg=aes_gcm-null,aes128-sha1,aes256-sha1,aes256-sha2_512,aes128-sha2,aes256-sha2
  sha2-truncbug=no

conn l2tp-psk
  auto=add
  leftprotoport=17/1701
  rightprotoport=17/%any
  type=transport
  phase2=esp
  also=shared

conn xauth-psk
  auto=add
  leftsubnet=0.0.0.0/0
  rightaddresspool=$IPSEC_DHCP_POOL
  modecfgdns=$DNS_SERVER
  leftxauthserver=yes
  rightxauthclient=yes
  leftmodecfgserver=yes
  rightmodecfgclient=yes
  modecfgpull=yes
  xauthby=file
  ike-frag=yes
  cisco-unity=yes
  also=shared

include /etc/ipsec.d/*.conf
EOF

# // Make PSK Key / IPSec PSK Keys
cat > /etc/ipsec.secrets <<EOF
%any  %any  : PSK "$IPSec_Key"
EOF

# // Make XL2TPD Configuration
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

[lns default]
ip range = $L2TP_DHCP_POOL
local ip = $L2TP_LOCAL
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

# // Configure L2TPD Options
cat > /etc/ppp/options.xl2tpd <<EOF
+mschap-v2
ipcp-accept-local
ipcp-accept-remote
noccp
auth
mtu 1280
mru 1280
proxyarp
lcp-echo-failure 4
lcp-echo-interval 30
connect-delay 5000
ms-dns ${DNS_SERVER_1}
ms-dns ${DNS_SERVER_2}
EOF

# // Making User Database Files
touch /etc/ppp/chap-secrets
touch /etc/ipsec.d/passwd

# // Create PPTP config
cat >/etc/pptpd.conf <<END
option /etc/ppp/options.pptpd
logwtmp
localip ${PPTP_GATEWAY}
remoteip ${PPTP_DHCP_POOL}
END

# // Configure PPTPD Option
cat >/etc/ppp/options.pptpd <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns ${DNS_SERVER_1}
ms-dns ${DNS_SERVER_2}
proxyarp
lock
nobsdcomp 
novj
novjccomp
nologfd
END

# // Adding L2TPD & PPTPD & IPSec To IPTables
iptables -t nat -I POSTROUTING -s 10.10.13.0/24 -o $NETWORK_IFACE -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.10.14.0/24 -o $NETWORK_IFACE -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.10.15.0/24 -o $NETWORK_IFACE -j MASQUERADE
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null 2>&1
netfilter-persistent reload > /dev/null 2>&1

# // Enabling  Fail2ban For IPSec
systemctl stop fail2ban
systemctl start fail2ban
for svc in fail2ban ipsec xl2tpd; do
  update-rc.d "$svc" enable >/dev/null 2>&1
  systemctl enable "$svc" 2>/dev/null
done

# //  Make Configuration Directory
cat > /etc/ppp/chap-secrets << END
# ==================================
# PPTP & L2TP User Data Config
# Created By autosc.me
# ==================================

# // PPTP User Data Configuration
#PPTP

# // L2TP User Data Configuration
#L2TP
END

# // Running Sysctl & Allow Permission For IPSec Secret & Chap Secret & Passwd Secret
sysctl -e -q -p > /dev/null 2>&1
chmod 600 /etc/ipsec.secrets* /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*

# // Make /dev/ppp & mknod For Fixing Eror On L2TP
rm -r -f /dev/ppp
mknod /dev/ppp c 108 0 
chmod 600 /dev/ppp

# // Enable Service & Starting Service
systemctl enable xl2tpd > /dev/null 2>&1
systemctl enable ipsec > /dev/null 2>&1
systemctl enable pptpd > /dev/null 2>&1
systemctl restart xl2tpd 
systemctl restart pptpd
systemctl restart ipsec

# // Remove Unused Files
rm -f /root/pptp-l2tp.sh
