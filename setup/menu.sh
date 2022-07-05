#!/bin/bash
# Menu Setup
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

# // Downloading SSH Menu
wget -q -O /usr/local/sbin/addssh "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/addssh.sh"
wget -q -O /usr/local/sbin/delssh "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/delssh.sh"
wget -q -O /usr/local/sbin/renewssh "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/renewssh.sh"
wget -q -O /usr/local/sbin/sshlogin "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/sshlogin.sh"
wget -q -O /usr/local/sbin/sshexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/sshexp.sh"
wget -q -O /usr/local/sbin/trialssh "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/trialssh.sh"
wget -q -O /usr/local/sbin/userssh "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssh/userssh.sh"

# // Adding Permission For Esac SSH Menu
chmod +x /usr/local/sbin/addssh
chmod +x /usr/local/sbin/delssh
chmod +x /usr/local/sbin/renewssh
chmod +x /usr/local/sbin/userssh
chmod +x /usr/local/sbin/sshlogin
chmod +x /usr/local/sbin/sshexp
chmod +x /usr/local/sbin/trialssh

# // Downloading Vmess Menu
wget -q -O /usr/local/sbin/addvmess "https://${Server_URL}/vpn-script/Stable/1.0/menu/vmess/addvmess.sh"
wget -q -O /usr/local/sbin/delvmess "https://${Server_URL}/vpn-script/Stable/1.0/menu/vmess/delvmess.sh"
wget -q -O /usr/local/sbin/renewvmess "https://${Server_URL}/vpn-script/Stable/1.0/menu/vmess/renewvmess.sh"
wget -q -O /usr/local/sbin/trialvmess "https://${Server_URL}/vpn-script/Stable/1.0/menu/vmess/trialvmess.sh"
wget -q -O /usr/local/sbin/vmessexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/vmess/vmessexp.sh"

# // Adding Permission For Esac Vmess Menu
chmod +x /usr/local/sbin/addvmess
chmod +x /usr/local/sbin/delvmess
chmod +x /usr/local/sbin/renewvmess
chmod +x /usr/local/sbin/trialvmess
chmod +x /usr/local/sbin/vmessexp

# // Downloading Vless Menu
wget -q -O /usr/local/sbin/addvless "https://${Server_URL}/vpn-script/Stable/1.0/menu/vless/addvless.sh"
wget -q -O /usr/local/sbin/delvless "https://${Server_URL}/vpn-script/Stable/1.0/menu/vless/delvless.sh"
wget -q -O /usr/local/sbin/renewvless "https://${Server_URL}/vpn-script/Stable/1.0/menu/vless/renewvless.sh"
wget -q -O /usr/local/sbin/trialvless "https://${Server_URL}/vpn-script/Stable/1.0/menu/vless/trialvless.sh"
wget -q -O /usr/local/sbin/vlessexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/vless/vlessexp.sh"

# // Adding Permission For Esac Vless Menu
chmod +x /usr/local/sbin/addvless
chmod +x /usr/local/sbin/delvless
chmod +x /usr/local/sbin/renewvless
chmod +x /usr/local/sbin/trialvless
chmod +x /usr/local/sbin/vlessexp

# // Downloading Shadowsocks Menu
wget -q -O /usr/local/sbin/addss "https://${Server_URL}/vpn-script/Stable/1.0/menu/ss/addss.sh"
wget -q -O /usr/local/sbin/delss "https://${Server_URL}/vpn-script/Stable/1.0/menu/ss/delss.sh"
wget -q -O /usr/local/sbin/renewss "https://${Server_URL}/vpn-script/Stable/1.0/menu/ss/renewss.sh"
wget -q -O /usr/local/sbin/trialss "https://${Server_URL}/vpn-script/Stable/1.0/menu/ss/trialss.sh"
wget -q -O /usr/local/sbin/ssexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/ss/ssexp.sh"

# // Adding Permission For Esac Shadowsocks Menu
chmod +x /usr/local/sbin/addss
chmod +x /usr/local/sbin/delss
chmod +x /usr/local/sbin/renewss
chmod +x /usr/local/sbin/trialss
chmod +x /usr/local/sbin/ssexp

# // Downloading ShadowsocksR Menu
wget -q -O /usr/local/sbin/addssr "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssr/addssr.sh"
wget -q -O /usr/local/sbin/delssr "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssr/delssr.sh"
wget -q -O /usr/local/sbin/renewssr "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssr/renewssr.sh"
wget -q -O /usr/local/sbin/trialssr "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssr/trialssr.sh"
wget -q -O /usr/local/sbin/ssrexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/ssr/ssrexp.sh"

# // Adding Permission For Esac ShadowsocksR Menu
chmod +x /usr/local/sbin/addssr
chmod +x /usr/local/sbin/delssr
chmod +x /usr/local/sbin/renewssr
chmod +x /usr/local/sbin/trialssr
chmod +x /usr/local/sbin/ssrexp

# // Downloading Trojan Menu
wget -q -O /usr/local/sbin/addtrojan "https://${Server_URL}/vpn-script/Stable/1.0/menu/trojan/addtrojan.sh"
wget -q -O /usr/local/sbin/deltrojan "https://${Server_URL}/vpn-script/Stable/1.0/menu/trojan/deltrojan.sh"
wget -q -O /usr/local/sbin/renewtrojan "https://${Server_URL}/vpn-script/Stable/1.0/menu/trojan/renewtrojan.sh"
wget -q -O /usr/local/sbin/trialtrojan "https://${Server_URL}/vpn-script/Stable/1.0/menu/trojan/trialtrojan.sh"
wget -q -O /usr/local/sbin/trojanexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/trojan/trojanexp.sh"

# // Adding Permission For Esac Trojan Menu
chmod +x /usr/local/sbin/addtrojan
chmod +x /usr/local/sbin/deltrojan
chmod +x /usr/local/sbin/renewtrojan
chmod +x /usr/local/sbin/trialtrojan
chmod +x /usr/local/sbin/trojanexp

# // Downloading PPTP Menu
wget -q -O /usr/local/sbin/addpptp "https://${Server_URL}/vpn-script/Stable/1.0/menu/pptp/addpptp.sh"
wget -q -O /usr/local/sbin/delpptp "https://${Server_URL}/vpn-script/Stable/1.0/menu/pptp/delpptp.sh"
wget -q -O /usr/local/sbin/renewpptp "https://${Server_URL}/vpn-script/Stable/1.0/menu/pptp/renewpptp.sh"
wget -q -O /usr/local/sbin/trialpptp "https://${Server_URL}/vpn-script/Stable/1.0/menu/pptp/trialpptp.sh"
wget -q -O /usr/local/sbin/pptpexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/pptp/pptpexp.sh"

# // Adding Permission For Esac PPTP Menu
chmod +x /usr/local/sbin/addpptp
chmod +x /usr/local/sbin/delpptp
chmod +x /usr/local/sbin/renewpptp
chmod +x /usr/local/sbin/trialpptp
chmod +x /usr/local/sbin/pptpexp

# // Downloading L2TP Menu
wget -q -O /usr/local/sbin/addl2tp "https://${Server_URL}/vpn-script/Stable/1.0/menu/l2tp/addl2tp.sh"
wget -q -O /usr/local/sbin/dell2tp "https://${Server_URL}/vpn-script/Stable/1.0/menu/l2tp/dell2tp.sh"
wget -q -O /usr/local/sbin/renewl2tp "https://${Server_URL}/vpn-script/Stable/1.0/menu/l2tp/renewl2tp.sh"
wget -q -O /usr/local/sbin/triall2tp "https://${Server_URL}/vpn-script/Stable/1.0/menu/l2tp/triall2tp.sh"
wget -q -O /usr/local/sbin/l2tpexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/l2tp/l2tpexp.sh"

# // Adding Permission For Esac L2TP Menu
chmod +x /usr/local/sbin/addl2tp
chmod +x /usr/local/sbin/dell2tp
chmod +x /usr/local/sbin/renewl2tp
chmod +x /usr/local/sbin/triall2tp
chmod +x /usr/local/sbin/l2tpexp

# // Downloading SSTP Menu
wget -q -O /usr/local/sbin/addsstp "https://${Server_URL}/vpn-script/Stable/1.0/menu/sstp/addsstp.sh"
wget -q -O /usr/local/sbin/delsstp "https://${Server_URL}/vpn-script/Stable/1.0/menu/sstp/delsstp.sh"
wget -q -O /usr/local/sbin/renewsstp "https://${Server_URL}/vpn-script/Stable/1.0/menu/sstp/renewsstp.sh"
wget -q -O /usr/local/sbin/trialsstp "https://${Server_URL}/vpn-script/Stable/1.0/menu/sstp/trialsstp.sh"
wget -q -O /usr/local/sbin/sstpexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/sstp/sstpexp.sh"

# // Adding Permission For Esac SSTP Menu
chmod +x /usr/local/sbin/addsstp
chmod +x /usr/local/sbin/delsstp
chmod +x /usr/local/sbin/renewsstp
chmod +x /usr/local/sbin/trialsstp
chmod +x /usr/local/sbin/sstpexp

# // Downloading Wireguard Menu
wget -q -O /usr/local/sbin/addwg "https://${Server_URL}/vpn-script/Stable/1.0/menu/wg/addwg.sh"
wget -q -O /usr/local/sbin/delwg "https://${Server_URL}/vpn-script/Stable/1.0/menu/wg/delwg.sh"
wget -q -O /usr/local/sbin/renewwg "https://${Server_URL}/vpn-script/Stable/1.0/menu/wg/renewwg.sh"
wget -q -O /usr/local/sbin/trialwg "https://${Server_URL}/vpn-script/Stable/1.0/menu/wg/trialwg.sh"
wget -q -O /usr/local/sbin/wgexp "https://${Server_URL}/vpn-script/Stable/1.0/menu/wg/wgexp.sh"

# // Adding Permission For Esac Wireguard Menu
chmod +x /usr/local/sbin/addwg
chmod +x /usr/local/sbin/delwg
chmod +x /usr/local/sbin/renewwg
chmod +x /usr/local/sbin/trialwg
chmod +x /usr/local/sbin/wgexp

# // Download Addons Tools
wget -q -O /usr/local/sbin/ram-usage "https://${Server_URL}/ram-usage.sh"
wget -q -O /usr/local/sbin/speedtest "https://${Server_URL}/ssh/speedtest_cli.py"
chmod +x /usr/local/sbin/ram-usage
chmod +x /usr/local/sbin/speedtest

# // Downlaoding Menu
wget -q -O /usr/local/sbin/ssh-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/ssh.sh"
wget -q -O /usr/local/sbin/vmess-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/vmess.sh"
wget -q -O /usr/local/sbin/vless-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/vless.sh"
wget -q -O /usr/local/sbin/ss-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/ss.sh"
wget -q -O /usr/local/sbin/ssr-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/ssr.sh"
wget -q -O /usr/local/sbin/wg-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/wireguard.sh"
wget -q -O /usr/local/sbin/pptp-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/pptp.sh"
wget -q -O /usr/local/sbin/l2tp-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/l2tp.sh"
wget -q -O /usr/local/sbin/sstp-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/sstp.sh"
wget -q -O /usr/local/sbin/trojan-manager "https://${Server_URL}/vpn-script/Stable/1.0/menu/manager/trojan.sh"

# // Adding Permission For Manager
chmod +x /usr/local/sbin/ssh-manager
chmod +x /usr/local/sbin/vmess-manager
chmod +x /usr/local/sbin/vless-manager
chmod +x /usr/local/sbin/ss-manager
chmod +x /usr/local/sbin/ssr-manager
chmod +x /usr/local/sbin/wg-manager
chmod +x /usr/local/sbin/pptp-manager
chmod +x /usr/local/sbin/l2tp-manager
chmod +x /usr/local/sbin/sstp-manager
chmod +x /usr/local/sbin/trojan-manager

# // Downloading Other Data
wget -q -O /usr/local/sbin/info "https://${Server_URL}/vpn-script/Stable/1.0/menu/info.sh"
wget -q -O /usr/local/sbin/info2 "https://${Server_URL}/vpn-script/Stable/1.0/menu/info2.sh"
wget -q -O /usr/local/sbin/menu "https://${Server_URL}/vpn-script/Stable/1.0/menu/menu.sh"
wget -q -O /usr/local/sbin/expall "https://${Server_URL}/vpn-script/Stable/1.0/menu/expall.sh"
wget -q -O /usr/local/sbin/backup "https://${Server_URL}/vpn-script/Stable/1.0/menu/recovery/backup.sh"
wget -q -O /usr/local/sbin/restore "https://${Server_URL}/vpn-script/Stable/1.0/menu/recovery/restore.sh"
wget -q -O /usr/local/sbin/addmail "https://${Server_URL}/vpn-script/Stable/1.0/menu/recovery/addmail.sh"
wget -q -O /usr/local/sbin/port-changer "https://${Server_URL}/vpn-script/Stable/1.0/menu/port-changer.sh"
wget -q -O /usr/local/sbin/vps-pointing "https://${Server_URL}/vpn-script/Stable/1.0/menu/pointing.sh"

# // Adding Permission For Other Data
chmod +x /usr/local/sbin/info
chmod +x /usr/local/sbin/info2
chmod +x /usr/local/sbin/menu
chmod +x /usr/local/sbin/expall
chmod +x /usr/local/sbin/backup
chmod +x /usr/local/sbin/restore
chmod +x /usr/local/sbin/addmail
chmod +x /usr/local/sbin/vps-pointing
chmod +x /usr/local/sbin/port-changer

# // Remove Not Used Files
rm -f /root/menu.sh
