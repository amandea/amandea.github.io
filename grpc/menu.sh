#!/bin/bash
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
yl='\e[32;1m'
bl='\e[36;1m'
gl='\e[32;1m'
rd='\e[31;1m'
mg='\e[0;95m'
blu='\e[34m'
op='\e[35m'
or='\033[1;33m'
bd='\e[1m'
color1='\e[031;1m'
color2='\e[34;1m'
color3='\e[0m'
clear
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
IZIN=$(wget -qO- ipinfo.io/ip);
clear 
echo -e ""
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
DOMAIN=$(cat /etc/xray/domain)
CITY=$(curl -s ipinfo.io/city )
up=$(uptime|awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }')
tram=$( free -m | awk 'NR==2 {print $2}' )
echo -e ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "\E[44;1;39m                     ⇱ INFORMASI VPS ⇲                        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e " ❇️$bd ISP Name          ${color1} •${color3}$bd $ISP"
echo -e " ❇️$bd City              ${color1} •${color3}$bd $CITY"
echo -e " ❇️$bd Total RAM         ${color1} •${color3}$bd $tram MB"
echo -e " ❇️$bd IP VPS            ${color1} •${color3}$bd $MYIP"
echo -e " ❇️$bd DOMAIN VPS        ${color1} •${color3}$bd $DOMAIN"
echo -e " ❇️$bd Waktu Aktif       ${color1} •${color3}$bd $up"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "\E[44;1;39m                     ⇱ MENU  OPTIONS ⇲                        \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "
[${green}01${NC}]${color1} •${color3}$bd Add Vmess Vless GRPC Account (${color2}Add-VGRPC${color3})
[${green}02${NC}]${color1} •${color3}$bd Cek Login Vmess Vless GRPC Account (${color2}Cek-VGRPC${color3})
[${green}03${NC}]${color1} •${color3}$bd Renew Vmess Vless GRPC Account (${color2}Renew-VGRPC${color3})
[${green}04${NC}]${color1} •${color3}$bd Delete Vmess Vless GRPC Account (${color2}Del-VGRPC${color3})
[${green}05${NC}]${color1} •${color3}$bd Add Trojan GRPC Account (${color2}Add-TGRPC${color3})
[${green}06${NC}]${color1} •${color3}$bd Cek Login Trojan GRPC Account (${color2}Cek-TGRPC${color3})
[${green}07${NC}]${color1} •${color3}$bd Renew Trojan GRPC Account (${color2}Renew-TGRPC${color3})
[${green}08${NC}]${color1} •${color3}$bd Delete Trojan GRPC Account (${color2}del-TGRPC${color3})
[${green}09${NC}]${color1} •${color3}$bd Addhost Domain Baru (${color2}addhost${color3})
[${green}10${NC}]${color1} •${color3}$bd Renew Cert (${color2}cert${color3})
[${green}11${NC}]${color1} •${color3}$bd Cek Layanan (${color2}Status${color3})
[${green}12${NC}]${color1} •${color3}$bd speedtest (${color2}speedtest${color3})

[${green}00${NC}]${color1} •${color3}$bd Back to exit Menu \033[1;32m<\033[1;33m<\033[1;31m<\033[1;31m"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e "\E[44;1;39m                     ⇱ FSIDVPN PROJECT ⇲                       \E[0m"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo -e  ""
 read -p "  Select menu :  " menu
echo -e   ""
case $menu in
1 | 01)
addgrpc
;;
2 | 02)
cekgrpc
;;
3 | 03)
renewgrpc
;;
4 | 04)
delgrpc
;;
5 | 05)
addtrgrpc
;;
6 | 06)
cektrgrpc
;;
7 | 07)
renewtrgrpc
;;
8 | 08)
deltrgrpc
;;
9 | 09)
addhost
;;
10)
cert
;;
11)
running
;;
12)
speedtest
;;
0 | 00)
menu
;;
*)
menu
;;
esac
