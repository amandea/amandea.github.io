#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

BURIQ () {
    curl -sS https://raw.githubusercontent.com/fsidvpn/perizinan/main/main/allow > /root/tmp
    data=( `cat /root/tmp | grep -E "^### " | awk '{print $2}'` )
    for user in "${data[@]}"
    do
    exp=( `grep -E "^### $user" "/root/tmp" | awk '{print $3}'` )
    d1=(`date -d "$exp" +%s`)
    d2=(`date -d "$biji" +%s`)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
    echo $user > /etc/.$user.ini
    else
    rm -f  /etc/.$user.ini > /dev/null 2>&1
    fi
    done
    rm -f  /root/tmp
}
 
MYIP=$(curl -sS ipv4.icanhazip.com)
Name=$(curl -sS https://raw.githubusercontent.com/fsidvpn/perizinan/main/main/allow | grep $MYIP | awk '{print $2}')
echo $Name > /usr/local/etc/.$Name.ini
CekOne=$(cat /usr/local/etc/.$Name.ini)

Bloman () {
if [ -f "/etc/.$Name.ini" ]; then
CekTwo=$(cat /etc/.$Name.ini)
    if [ "$CekOne" = "$CekTwo" ]; then
        res="Expired"
    fi
else
res="Permission Accepted..."
fi
}

PERMISSION () {
    MYIP=$(curl -sS ipv4.icanhazip.com)
    IZIN=$(curl -sS https://raw.githubusercontent.com/fsidvpn/perizinan/main/main/allow | awk '{print $4}' | grep $MYIP)
    if [ "$MYIP" = "$IZIN" ]; then
    Bloman
    else
    res="Permission Denied!"
    fi
    BURIQ
}

clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\e[0m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
cd /root
#System version number
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi

echo -e "[ ${tyblue}NOTES${NC} ] Before we go.. "
sleep 1
echo -e "[ ${tyblue}NOTES${NC} ] I need check your headers first.."
sleep 2
echo -e "[ ${green}INFO${NC} ] Checking headers"
sleep 1
totet=`uname -r`
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  sleep 2
  echo -e "[ ${yell}WARNING${NC} ] Try to install ...."
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  apt-get --yes install $REQUIRED_PKG
  sleep 1
  echo ""
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] If error you need.. to do this"
  sleep 1
  echo ""
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 1. apt update -y"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 2. apt upgrade -y"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 3. apt dist-upgrade -y"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] 4. reboot"
  sleep 1
  echo ""
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] After rebooting"
  sleep 1
  echo -e "[ ${tyblue}NOTES${NC} ] Then run this script again"
  echo -e "[ ${tyblue}NOTES${NC} ] if you understand then tap enter now"
  read
else
  echo -e "[ ${green}INFO${NC} ] Oke installed"
fi

ttet=`uname -r`
ReqPKG="linux-headers-$ttet"
if ! dpkg -s $ReqPKG  >/dev/null 2>&1; then
  rm /root/setup.sh >/dev/null 2>&1 
  exit
else
  clear
fi


secs_to_human() {
    echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

coreselect=''
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
screen -r setup
END
chmod 644 /root/.profile

echo -e "[ ${green}INFO${NC} ] Preparing the install file"
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aight good ... installation file is ready"
sleep 2
echo -ne "[ ${green}INFO${NC} ] Check permission : "

PERMISSION
if [ -f /home/needupdate ]; then
red "Your script need to update first !"
exit 0
elif [ "$res" = "Permission Accepted..." ]; then
green "Permission Accepted!"
else
red "Permission Denied!"
rm setup.sh > /dev/null 2>&1
sleep 10
exit 0
fi

sleep 3
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
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
# Link Hosting Kalian Untuk Ssh Vpn
akbarvpn="autosc.me/p/ssh"
# Link Hosting Kalian Untuk Sstp
akbarvpnn="autosc.me/p/sstp"
# Link Hosting Kalian Untuk Ssr
akbarvpnnn="autoscme/p/ssr"
# Link Hosting Kalian Untuk Shadowsocks
akbarvpnnnn="autosc.me/p/shadowsocks"
# Link Hosting Kalian Untuk Wireguard
akbarvpnnnnn="autosc.me/p/wireguard"
# Link Hosting Kalian Untuk Xray
akbarvpnnnnnn="autosc.me/p/xray"
# Link Hosting Kalian Untuk Ipsec
akbarvpnnnnnnn="autosc.me/p/ipsec"
# Link Hosting Kalian Untuk Backup
akbarvpnnnnnnnn="autosc.me/p/backup"
# Link Hosting Kalian Untuk Websocket
akbarvpnnnnnnnnn="autosc.me/p/websocket"
# Link Hosting Kalian Untuk Ohp
akbarvpnnnnnnnnnn="autosc.me/p/ohp"
# Getting
rm -f setup.sh
clear
echo -e "[ ${green}INFO${NC} ] Checking... "
if [ -f "/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 0
fi
mkdir /var/lib/fsidvpn;
echo "IP=" >> /var/lib/fsidvpn/ipvps.conf
echo -e "[ ${green}INFO${NC} ] Configurasi Domain... "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpn}/cf.sh >/dev/null 2>&1
chmod +x cf.sh >/dev/null 2>&1
./cf.sh >/dev/null 2>&1
#install v2ray
echo -e "[ ${green}INFO${NC} ] Installing... XRAY"
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnnnn}/ins-xray.sh >/dev/null 2>&1
chmod +x ins-xray.sh >/dev/null 2>&1
screen -S xray ./ins-xray.sh >/dev/null 2>&1
#install ssh ovpn
echo -e "[ ${green}INFO${NC} ] Installing... SSH & VPN "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpn}/ssh-vpn.sh >/dev/null 2>&1
chmod +x ssh-vpn.sh >/dev/null 2>&1
screen -S ssh-vpn ./ssh-vpn.sh >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Installing... SSTP "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnn}/sstp.sh >/dev/null 2>&1
chmod +x sstp.sh >/dev/null 2>&1
screen -S sstp ./sstp.sh >/dev/null 2>&1
#install ssr
echo -e "[ ${green}INFO${NC} ] Installing... SSR "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://autosc.me/ssr/ssr.sh >/dev/null 2>&1
chmod +x ssr.sh >/dev/null 2>&1
screen -S ssr ./ssr.sh >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Installing... Shadowsocks"
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnn}/sodosok.sh >/dev/null 2>&1
chmod +x sodosok.sh >/dev/null 2>&1
screen -S ss ./sodosok.sh >/dev/null 2>&1
#installwg
echo -e "[ ${green}INFO${NC} ] Installing... Wireguard "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnnn}/wg.sh >/dev/null 2>&1
chmod +x wg.sh >/dev/null 2>&1
screen -S wg ./wg.sh >/dev/null 2>&1
#install L2TP
echo -e "[ ${green}INFO${NC} ] Installing... Ipsec "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnnnnn}/ipsec.sh >/dev/null 2>&1
chmod +x ipsec.sh >/dev/null 2>&1
screen -S ipsec ./ipsec.sh >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Installing... Auto Backup "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnnnnnn}/set-br.sh >/dev/null 2>&1
chmod +x set-br.sh >/dev/null 2>&1
./set-br.sh >/dev/null 2>&1
# Websocket
echo -e "[ ${green}INFO${NC} ] Installing... Websocket "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnnnnnnn}/edu.sh >/dev/null 2>&1
chmod +x edu.sh >/dev/null 2>&1
./edu.sh >/dev/null 2>&1
# Ohp Server
echo -e "[ ${green}INFO${NC} ] Installing... OHP "
sleep 1
echo -e ""
date
echo -e ""
sleep 1
wget https://${akbarvpnnnnnnnnnn}/ohp.sh >/dev/null 2>&1
chmod +x ohp.sh && ./ohp.sh >/dev/null 2>&1

rm -f /root/ssh-vpn.sh >/dev/null 2>&1
rm -f /root/sstp.sh >/dev/null 2>&1
rm -f /root/wg.sh >/dev/null 2>&1
rm -f /root/ss.sh >/dev/null 2>&1
rm -f /root/ssr.sh >/dev/null 2>&1
rm -f /root/ins-xray.sh >/dev/null 2>&1
rm -f /root/ipsec.sh >/dev/null 2>&1
rm -f /root/set-br.sh >/dev/null 2>&1
rm -f /root/edu.sh >/dev/null 2>&1
rm -f /root/ohp.sh >/dev/null 2>&1
rm -r -f domain >/dev/null 2>&1
cat <<EOF> /etc/systemd/system/autosett.service
[Unit]
Description=autosetting
Documentation=https://t.me/fer1dev

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/set.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable autosett
wget -O /etc/set.sh "https://${akbarvpn}/set.sh" >/dev/null 2>&1
chmod +x /etc/set.sh >/dev/null 2>&1
history -c
echo "1.2" > /home/ver
echo " "
echo "Installation has been completed!!"
echo " "
echo "=================================-AutoScript By FsidVPN Project-===========================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "----------------------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 990"  | tee -a log-install.txt
echo "   - Stunnel5                : 443, 445, 777"  | tee -a log-install.txt
echo "   - Dropbear                : 109, 143"  | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8080"  | tee -a log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 89"  | tee -a log-install.txt
echo "   - Wireguard               : 7070"  | tee -a log-install.txt
echo "   - L2TP/IPSEC VPN          : 1701"  | tee -a log-install.txt
echo "   - PPTP VPN                : 1732"  | tee -a log-install.txt
echo "   - SSTP VPN                : 444"  | tee -a log-install.txt
echo "   - Shadowsocks-R           : 1443-1543"  | tee -a log-install.txt
echo "   - SS-OBFS TLS             : 2443-2543"  | tee -a log-install.txt
echo "   - SS-OBFS HTTP            : 3443-3543"  | tee -a log-install.txt
echo "   - XRAYS Vmess TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vmess None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Vless TLS         : 8443"  | tee -a log-install.txt
echo "   - XRAYS Vless None TLS    : 80"  | tee -a log-install.txt
echo "   - XRAYS Trojan            : 2083"  | tee -a log-install.txt
echo "   - Websocket TLS           : 443"  | tee -a log-install.txt
echo "   - Websocket None TLS      : 8880"  | tee -a log-install.txt
echo "   - Websocket Ovpn          : 2086"  | tee -a log-install.txt
echo "   - OHP SSH                 : 8181"  | tee -a log-install.txt
echo "   - OHP Dropbear            : 8282"  | tee -a log-install.txt
echo "   - OHP OpenVPN             : 8383"  | tee -a log-install.txt
echo "   - Tr Go                   : 2087"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On 05.00 GMT +7" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo "   - White Label" | tee -a log-install.txt
echo "   - Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   - Dev/Main                : Horas Marolop Amsal Siregar"  | tee -a log-install.txt
echo "   - Recode                  : Fsid Vpn" | tee -a log-install.txt
echo "   - Telegram                : https://t.me/FER1DEV"  | tee -a log-install.txt
echo "   - Instagram               : ~"  | tee -a log-install.txt
echo "   - Whatsapp                : 088228877739"  | tee -a log-install.txt
echo "   - Facebook                : https://m.facebook.com/edoy.caquarius" | tee -a log-install.txt
echo "----------------------AutoScript By FsidVPN Project----------------------" | tee -a log-install.txt
echo ""
echo " Reboot 15 Sec"
sleep 15
rm -f setup.sh
rm -f TRIAL
rm -f PREM
reboot

