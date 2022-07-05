#!/bin/bash
# ==========================================
systemctl stop xray.service
clear
tr="$(cat ~/log-install.txt | grep -w "Trojan" | cut -d: -f2|sed 's/ //g')"
echo -e "======================================"
echo -e ""
echo -e "Change Port $tr"
echo -e ""
echo -e "======================================"
read -p "New Port Trojan : " tr2
if [ -z $tr2 ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $tr2)
if [[ -z $cek ]]; then
sed -i "s/$tr/$tr2/g" /etc/xray/config.json
sed -i "s/   - XRAYS Trojan            : $tr/   - XRAYS Trojan            : $tr2/g" /root/log-install.txt
iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport $tr -j ACCEPT
iptables -D INPUT -m state --state NEW -m udp -p udp --dport $tr -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $tr2 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport $tr2 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save > /dev/null
netfilter-persistent reload > /dev/null
systemctl restart xray.service > /dev/null
echo -e "\e[032;1mPort $tr2 modified successfully\e[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"

menu
else
echo "Port $tr2 is used"
sleep 5
porttrojan
fi
