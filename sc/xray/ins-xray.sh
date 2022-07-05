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
    rm -f /etc/.$user.ini > /dev/null 2>&1
    fi
    done
    rm -f /root/tmp
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
NC='\e[0m'
curl -sS https://autosc.me/sc/resources/ascii-home
echo "XRAY Core Vmess / Vless"
echo "Trojan / Trojan Go"
echo "Progress..."
sleep 3
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
PERMISSION
if [ "$res" = "Permission Accepted..." ]; then
green "Permission Accepted.."
else
red "Permission Denied!"
exit 0
fi
echo -e "
"
date
echo ""
domain=$(cat /root/domain)
sleep 1
mkdir -p /etc/xray > /dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Checking... "
apt install iptables iptables-persistent -y >/dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Setting ntpdate"
ntpdate pool.ntp.org >/dev/null 2>&1
timedatectl set-ntp true >/dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chronyd"
systemctl enable chronyd >/dev/null 2>&1
systemctl restart chronyd >/dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chrony"
systemctl enable chrony >/dev/null 2>&1
systemctl restart chrony >/dev/null 2>&1
timedatectl set-timezone Asia/Jakarta >/dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Setting chrony tracking"
chronyc sourcestats -v >/dev/null 2>&1
chronyc tracking -v >/dev/null 2>&1

mkdir -p /etc/trojan-go/ >/dev/null 2>&1
touch /etc/trojan-go/akun.conf >/dev/null 2>&1
# install xray
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
wget -q "https://autosc.me/sc/core/xray-core.sh" && chmod +x xray-core.sh && ./xray-core.sh >/dev/null 2>&1
rm -f xray-core.sh
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing Trojan-Go"
wget -q "https://autosc.me/sc/trojan/ins-trojango.sh" && chmod +x ins-trojango.sh && ./ins-trojango.sh
rm -f /root/ins-trojango.sh
mkdir -p /root/.acme.sh >/dev/null 2>&1
sleep 1
if [ -f "/etc/xray/domain" ]; then
echo -e "[ ${green}INFO$NC ] Current domain for acme : $domain"
else
echo -e "[ ${green}INFO$NC ] Getting acme for cert"
source <(curl -sL https://get.acme.sh) >/dev/null 2>&1 | sh -s email=awaledyan@gmail.com
cd
/root/.acme.sh/acme.sh --register-account -m awaledyan@gmail.com
/root/.acme.sh/acme.sh --issue -d $domain --debug --standalone --keylength ec-256
#/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
fi
service squid start >/dev/null 2>&1
cat /proc/sys/kernel/random/uuid > /etc/xray/idvmesstls
cat /proc/sys/kernel/random/uuid > /etc/xray/idvmess
cat /proc/sys/kernel/random/uuid > /etc/xray/idvlesstls
cat /proc/sys/kernel/random/uuid > /etc/xray/idvless
cat /proc/sys/kernel/random/uuid > /etc/xray/idtrojantls
cat /proc/sys/kernel/random/uuid > /etc/xray/idvlessmkctls
cat /proc/sys/kernel/random/uuid > /etc/xray/idvlessmkc
if [ ! -f /etc/trojan-go/idtrojango ]; then
cat /proc/sys/kernel/random/uuid > /etc/trojan-go/idtrojango
fi
uidVmessTLS=$(cat /etc/xray/idvmesstls)
uidVmess=$(cat /etc/xray/idvmess)
uidVlessTLS=$(cat /etc/xray/idvlesstls)
uidVless=$(cat /etc/xray/idvless)
uidTrojanTLS=$(cat /etc/xray/idtrojantls)
uidVlessMkcTLS=$(cat /etc/xray/idvlessmkctls)
uidVlessMkc=$(cat /etc/xray/idvlessmkc)
uidTrojanGo=$(cat /etc/trojan-go/idtrojango)
sleep 1
echo -e "[ ${green}INFO$NC ] Setting config xray/vmess"

cat> /etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 29848,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "port": 443,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$uidVmessTLS",
            "alterId": 0
#vmessWSTLS
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
              "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
            }
          ]
        },
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/xrayws",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "domain": "${domain}",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$uidVmess",
            "alterId": 0
#vmessWS
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/xrayws",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uidVlessTLS"
#vlessWSTLS
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
              "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
            }
          ],
          "alpn": [
            "http/1.1"
          ]
        },
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/vlessws",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "domain": "${domain}",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uidVless"
#vlessWS
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/vlessws",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 8443,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$uidTrojanTLS"
#trojanTLS
          }
        ],
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
              "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
            }
          ],
          "alpn": [
            "http/1.1"
          ]
        },
        "tcpSettings": {},
        "kcpSettings": {},
        "wsSettings": {},
        "httpSettings": {},
        "quicSettings": {},
        "grpcSettings": {}
      },
      "domain": "${domain}",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 8101,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uidVlessMkcTLS"
#vlessMKCwgTLS
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "kcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
              "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
            }
          ]
        },
        "tcpSettings": {},
        "httpSettings": {},
        "kcpSettings": {
          "mtu": 1350,
          "tti": 50,
          "uplinkCapacity": 100,
          "downlinkCapacity": 100,
          "congestion": false,
          "readBufferSize": 2,
          "writeBufferSize": 2,
          "header": {
            "type": "wireguard"
          },
          "seed": "vlessmkctls"
        },
        "wsSettings": {},
        "quicSettings": {}
      },
      "domain": "${domain}",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 8111,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uidVlessMkc"
#vlessMKCwg
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "kcp",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "httpSettings": {},
        "kcpSettings": {
          "mtu": 1350,
          "tti": 50,
          "uplinkCapacity": 100,
          "downlinkCapacity": 100,
          "congestion": false,
          "readBufferSize": 2,
          "writeBufferSize": 2,
          "header": {
            "type": "wireguard"
          },
          "seed": "vlessmkc"
        },
        "wsSettings": {},
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

cat <<EOF> /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/xray/xray -config /etc/xray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

sleep 1
echo -e "[ ${green}INFO$NC ] Setting config trojan-go"
cat <<EOF > /etc/trojan-go/config.json
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2096,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "log_level": 1,
  "log_file": "/var/log/trojan-go.log",
  "password": [
        "$uidTrojanGo"
  ],
  "disable_http_check": true,
  "udp_timeout": 60,
  "ssl": {
    "verify": false,
    "verify_hostname": false,
    "cert": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
    "key": "/root/.acme.sh/${domain}_ecc/${domain}.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "",
    "fallback_port": 0,
    "fingerprint": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": true
  },
  "websocket": {
    "enabled": true,
    "path": "/scvps",
    "host": "${domain}"
  },
  "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}
EOF

sleep 1
echo -e "[ ${green}INFO$NC ] Creating service trojan-go"
cat <<EOF> /etc/systemd/system/trojan-go.service
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart="/usr/local/bin/trojan-go" -config "/etc/trojan-go/config.json"
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target

EOF
chmod +x /etc/trojan-go/config.json

cat <<EOF > /etc/trojan-go/uuid.txt
$uuid
EOF

sleep 1
echo -e "[ ${green}INFO$NC ] Installing bbr.."
wget -q -O /usr/bin/bbr "https://raw.githubusercontent.com/scvps/scriptvps/main/dll/bbr.sh"
chmod +x /usr/bin/bbr
bbr >/dev/null 2>&1
rm /usr/bin/bbr >/dev/null 2>&1

sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2096 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2087 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2083 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8880 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8101 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8111 -j ACCEPT

sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2096 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2087 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2083 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8880 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8101 -j ACCEPT
sudo iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8111 -j ACCEPT
sudo iptables-save > /etc/iptables.up.rules
sudo iptables-restore -t < /etc/iptables.up.rules
sudo netfilter-persistent save >/dev/null 2>&1
sudo netfilter-persistent reload >/dev/null 2>&1
echo -e "$yell[SERVICE]$NC Restart All service"
systemctl daemon-reload
sleep 1
echo -e "[ ${green}ok${NC} ] Enable & restart xray "
systemctl enable xray >/dev/null 2>&1
systemctl restart xray >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Enable & restart trojan-go "
systemctl enable trojan-go >/dev/null 2>&1
systemctl restart trojan-go >/dev/null 2>&1

sleep 1
echo -e "[ ${green}ok${NC} ] Downloading files for trojan-go... "
wget -q -O /usr/bin/add-ws "https://autosc.me/sc/xray/add-ws.sh" && chmod +x /usr/bin/add-ws
wget -q -O /usr/bin/add-vless "https://autosc.me/sc/xray/add-vless.sh" && chmod +x /usr/bin/add-vless
wget -q -O /usr/bin/add-tr "https://autosc.me/sc/xray/add-tr.sh" && chmod +x /usr/bin/add-tr
wget -q -O /usr/bin/del-ws "https://autosc.me/sc/xray/del-ws.sh" && chmod +x /usr/bin/del-ws
wget -q -O /usr/bin/del-vless "https://autosc.me/sc/xray/del-vless.sh" && chmod +x /usr/bin/del-vless
wget -q -O /usr/bin/del-tr "https://autosc.me/sc/xray/del-tr.sh" && chmod +x /usr/bin/del-tr
wget -q -O /usr/bin/cek-ws "https://autosc.me/sc/xray/cek-ws.sh" && chmod +x /usr/bin/cek-ws
wget -q -O /usr/bin/cek-vless "https://autosc.me/sc/xray/cek-vless.sh" && chmod +x /usr/bin/cek-vless
wget -q -O /usr/bin/cek-tr "https://autosc.me/sc/xray/cek-tr.sh" && chmod +x /usr/bin/cek-tr
wget -q -O /usr/bin/renew-ws "https://autosc.me/sc/xray/renew-ws.sh" && chmod +x /usr/bin/renew-ws
wget -q -O /usr/bin/renew-vless "https://autosc.me/sc/xray/renew-vless.sh" && chmod +x /usr/bin/renew-vless
wget -q -O /usr/bin/renew-tr "https://autosc.me/sc/xray/renew-tr.sh" && chmod +x /usr/bin/renew-tr
wget -q -O /usr/bin/trial-ws "https://autosc.me/sc/xray/trial-ws.sh" && chmod +x /usr/bin/trial-ws
wget -q -O /usr/bin/trial-vless "https://autosc.me/sc/xray/trial-vless.sh" && chmod +x /usr/bin/trial-vless
wget -q -O /usr/bin/trial-tr "https://autosc.me/sc/xray/trial-tr.sh" && chmod +x /usr/bin/trial-tr
wget -q -O /usr/bin/port-ws "https://autosc.me/sc/xray/port-ws.sh" && chmod +x /usr/bin/port-ws
wget -q -O /usr/bin/port-vless "https://autosc.me/sc/xray/port-vless.sh" && chmod +x /usr/bin/port-vless
wget -q -O /usr/bin/port-tr "https://autosc.me/sc/xray/port-tr.sh" && chmod +x /usr/bin/port-tr

wget -q -O /usr/bin/renewcert "https://autosc.me/sc/xray/cert.sh" && chmod +x /usr/bin/renewcert
#===baru===
wget -q -O /usr/bin/add-trgo "https://autosc.me/sc/trojan/add-trgo.sh" && chmod +x /usr/bin/add-trgo
wget -q -O /usr/bin/renew-trgo "https://autosc.me/sc/trojan/renew-trgo.sh" && chmod +x /usr/bin/renew-trgo
wget -q -O /usr/bin/cek-trgo "https://autosc.me/sc/trojan/cek-trgo.sh" && chmod +x /usr/bin/cek-trgo
wget -q -O /usr/bin/del-trgo "https://autosc.me/sc/trojan/del-trgo.sh" && chmod +x /usr/bin/del-trgo
wget -q -O /usr/bin/trial-trgo "https://autosc.me/sc/trojan/trial-trgo.sh" && chmod +x /usr/bin/trial-trgo
wget -q -O /usr/bin/port-trgo "https://autosc.me/sc/trojan/port-trgo.sh" && chmod +x /usr/bin/port-trgo

wget -q -O /usr/bin/v2ray-menu "https://autosc.me/sc/menu_all/v2ray-menu.sh" && chmod +x /usr/bin/v2ray-menu
wget -q -O /usr/bin/trojan-menu "https://autosc.me/sc/menu_all/trojan-menu.sh" && chmod +x /usr/bin/trojan-menu

sleep 1
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"
yellow "Trojan-GFW"
yellow "Trojan-GO install successfully"

mv /root/domain /etc/xray/ >/dev/null 2>&1
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
clear
touch /etc/trojan-go/akun.conf
rm -f ins-xray.sh >/dev/null 2>&1
