#!/bin/bash

#Database Details
HOST='104.218.54.211';
USER='atelprov_atervg';
PASS='@@Alaminbd';
DBNAME='atelprov_atervg';

echo -e "\e[1;32m Installing Server \033[0m"
sleep 3

echo -e "\033[01;31m Updating System \033[0m"

apt-get update -y > /dev/null 2>&1
chmod -x /etc/update-motd.d/*
apt-get install inxi screenfetch ansiweather -y  > /dev/null 2>&1

/bin/cat <<"EOM" >/etc/update-motd.d/01-custom
#!/bin/sh
/usr/bin/screenfetch
echo
echo "SYSTEM DISK USAGE"
export TERM=xterm; inxi -D
echo
echo "CURRENT WEATHER AT THE LOCATION"
ansiweather -l manila
EOM

chmod +x /etc/update-motd.d/01-custom

function ip_address(){
  IP="$( ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( curl -4 -s ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( curl -4 -s ipinfo.io/ip )"
  [ -n "${IP}" ] && echo "${IP}" || echo
  local IP
} 
MYIP=$(ip_address)

echo -e "\e[1;32m Done Updating \033[0m"
sleep 2

echo -e "\033[01;31m Allowing Downgrades \033[0m"
DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -q -y -u  -o Dpkg::Options::="--force-confdef" --allow-downgrades --allow-remove-essential --allow-change-held-packages --allow-unauthenticated > /dev/null 2>&1
echo -e "\e[1;32m Done Allowing Downgrades  \033[0m"
sleep 2

echo -e "\033[01;31m Installing Packages \033[0m"
apt install mysql-client php php-mysqli php-mysql php-gd php-mbstring -y
apt install php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap -y
apt install apache2 sudo nano fail2ban unzip python build-essential curl build-essential libwrap0-dev libpam0g-dev libdbus-1-dev libreadline-dev libnl-route-3-dev libprotobuf-c0-dev libpcl1-dev libopts25-dev autogen libgnutls28-dev libseccomp-dev libhttp-parser-dev php libapache2-mod-php -y
apt install screen openvpn easy-rsa -y
echo -e "\e[1;32m Done Installing Packages  \033[0m"
sleep 2

echo -e "\033[01;31m Compiling Openvpn Files \033[0m"
mkdir -p /etc/openvpn/easy-rsa/keys
mkdir -p /etc/openvpn/login
mkdir -p /etc/openvpn/radius
mkdir -p /var/www/html/stat
touch /etc/openvpn/server.conf
touch /etc/openvpn/server2.conf
touch /etc/openvpn/server3.conf

echo 'mode server 
tls-server 
port 55 
proto udp 
dev tun
keepalive 1 180
max-clients 1000
resolv-retry infinite 
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env # 
tmp-dir "/etc/openvpn/" # 
server 172.20.0.0 255.255.255.0
push "redirect-gateway def1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "sndbuf 393216"
push "rcvbuf 393216"
tun-mtu 1400 
mssfix 1360
verb 3
#comp-lzo
script-security 3
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log server_log
status /var/www/html/stat/udpstatus.txt
ifconfig-pool-persist /var/www/html/stat/ipp.txt' > /etc/openvpn/server.conf

echo 'mode server 
tls-server 
port 1194
proto tcp
dev tun
keepalive 1 180
max-clients 1000
resolv-retry infinite 
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env # 
tmp-dir "/etc/openvpn/" # 
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "sndbuf 393216"
push "rcvbuf 393216"
tun-mtu 1400 
mssfix 1360
verb 3
#comp-lzo
script-security 3
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log server2_log
status /var/www/html/stat/status.txt
ifconfig-pool-persist /var/www/html/stat/ipp.txt' > /etc/openvpn/server2.conf

echo 'mode server 
tls-server 
port 1147
proto tcp
dev tun
keepalive 1 180
max-clients 1000
resolv-retry infinite 
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env # 
tmp-dir "/etc/openvpn/" # 
server 10.9.0.0 255.255.255.0
push "redirect-gateway def1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "sndbuf 393216"
push "rcvbuf 393216"
tun-mtu 1400 
mssfix 1360
verb 3
#comp-lzo
script-security 3
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
status /var/www/html/stat/udpstatus2.txt
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log server3_log
ifconfig-pool-persist /var/www/html/stat/ipp.txt' > /etc/openvpn/server3.conf

cat <<\EOM >/etc/openvpn/login/config.sh
#!/bin/bash
HOST='DBHOST'
USER='DBUSER'
PASS='DBPASS'
DB='DBNAME'
EOM

sed -i "s|DBHOST|$HOST|g" /etc/openvpn/login/config.sh
sed -i "s|DBUSER|$USER|g" /etc/openvpn/login/config.sh
sed -i "s|DBPASS|$PASS|g" /etc/openvpn/login/config.sh
sed -i "s|DBNAME|$DBNAME|g" /etc/openvpn/login/config.sh

/bin/cat <<"EOM" >/etc/openvpn/login/auth_vpn
#!/bin/bash
. /etc/openvpn/login/config.sh
Query="SELECT user_name FROM users WHERE user_name='$username' AND user_encryptedPass=md5('$password') AND is_freeze='0' AND user_duration > 0"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM

#client-connect file
cat <<'LENZ05' >/etc/openvpn/login/connect.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/login/config.sh

##set status online to user connected
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_active='1' AND device_connected='1' WHERE user_name='$common_name' "

LENZ05

#TCP client-disconnect file
cat <<'LENZ06' >/etc/openvpn/login/disconnect.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/login/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_active='0' WHERE user_name='$common_name' "
LENZ06

cat << EOF > /etc/openvpn/easy-rsa/keys/ca.crt
-----BEGIN CERTIFICATE-----
MIIFDDCCA/SgAwIBAgIJAPVaxZZ9crxTMA0GCSqGSIb3DQEBCwUAMIG0MQswCQYD
VQQGEwJCRDEOMAwGA1UECBMFRGhha2ExDjAMBgNVBAcTBURoYWthMRgwFgYDVQQK
Ew9BMlogU0VSVkVSUyBMVEQxFzAVBgNVBAsTDmEyenNlcnZlcnMuY29tMRcwFQYD
VQQDEw5hMnpzZXJ2ZXJzLmNvbTESMBAGA1UEKRMJQkRFYXN5UlNBMSUwIwYJKoZI
hvcNAQkBFhZzdXBwb3J0QGEyenNlcnZlcnMuY29tMB4XDTIwMDYyNjA1NDM0NloX
DTMwMDYyNDA1NDM0NlowgbQxCzAJBgNVBAYTAkJEMQ4wDAYDVQQIEwVEaGFrYTEO
MAwGA1UEBxMFRGhha2ExGDAWBgNVBAoTD0EyWiBTRVJWRVJTIExURDEXMBUGA1UE
CxMOYTJ6c2VydmVycy5jb20xFzAVBgNVBAMTDmEyenNlcnZlcnMuY29tMRIwEAYD
VQQpEwlCREVhc3lSU0ExJTAjBgkqhkiG9w0BCQEWFnN1cHBvcnRAYTJ6c2VydmVy
cy5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCRUlPZAvENlXG
5r1EmX2BGwECWVFW9nrnXxIfx0Ia+04tlA17TGuRmRhH3irQAXjbXr8TBkx9Ttqy
eMdzUPzlTY8LZnVg/pwOkdxpODSB5/Icy0527d4492wbLp1XJdXJky/zEbW0jZF2
K6nXVtBIezFni/jj4xoWCnaWAGaM1jgysa0bsxCoHCJ6pG5Ih+Q3XX03FSBGbHtq
TebdzY5LzInckLNLA5qk39qo3PZzSPC6u2voZxqK0/Wrwa9nHPlCjX5nlOn7A+/8
IwHrD1qM0mja7AGW6bVSC+tnc9+YYz2p1bVY9yPS9E7OoWRN64Gz5AhlZjLLREuT
zoAZd2EnAgMBAAGjggEdMIIBGTAdBgNVHQ4EFgQU7YzIByeyPY8NFjG0ZGQb3cj0
s/QwgekGA1UdIwSB4TCB3oAU7YzIByeyPY8NFjG0ZGQb3cj0s/ShgbqkgbcwgbQx
CzAJBgNVBAYTAkJEMQ4wDAYDVQQIEwVEaGFrYTEOMAwGA1UEBxMFRGhha2ExGDAW
BgNVBAoTD0EyWiBTRVJWRVJTIExURDEXMBUGA1UECxMOYTJ6c2VydmVycy5jb20x
FzAVBgNVBAMTDmEyenNlcnZlcnMuY29tMRIwEAYDVQQpEwlCREVhc3lSU0ExJTAj
BgkqhkiG9w0BCQEWFnN1cHBvcnRAYTJ6c2VydmVycy5jb22CCQD1WsWWfXK8UzAM
BgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCe09DqQ/yhLffM5KCdd3UN
W41KF32do7WVYvzKAdlXPhByuPFaBXtOadCkclRg/opj2k6RBz4hmQCCUk4AxL/o
qG/FOseB33eWAs8GwuuocjRoUiHk6gMTNUcdGaJQASzLHU60WBIUK5enFf2m359p
qOhty1KzLIC5rgnVAnSglC7i/3hpO+KZKO8qoMVeMNE9ppOEnuQ3gCwnSdjjxFNQ
SgjBWmj9lzKK4js9D26CgQQiwdW+95WJqoqpO5y6Y0pVqx3xx3jsE1JokITW8zcd
at3rXO5wG4s+N1cS/b4eRRF1wQnYZIOhsyprYYWS6fOptt1fdq3iVhYhBEUXSfFm
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=BD, ST=Dhaka, L=Dhaka, O=A2Z SERVERS LTD, OU=a2zservers.com, CN=a2zservers.com/name=BDEasyRSA/emailAddress=support@a2zservers.com
        Validity
            Not Before: Jun 26 05:45:53 2020 GMT
            Not After : Jun 24 05:45:53 2030 GMT
        Subject: C=BD, ST=Dhaka, L=Dhaka, O=A2Z Servers Ltd, OU=A2Z Servers, CN=a2zservers.com/name=BDEasyRSA/emailAddress=support@a2zservers.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ea:39:b8:b8:ea:cc:27:d4:97:0f:08:74:52:f6:
                    25:19:95:e7:39:2d:c9:d5:1b:3f:10:0e:b2:94:29:
                    c2:cc:ee:6c:a6:49:15:06:e5:24:35:41:47:26:41:
                    ae:25:f4:77:a8:59:93:84:de:f8:05:a8:93:5d:06:
                    21:09:7c:b6:0d:d2:a2:68:94:fd:0a:f6:71:cd:b1:
                    65:a0:02:5a:0c:0b:33:0a:5c:06:82:c4:1f:de:70:
                    cd:66:c6:82:27:e1:e4:3c:e4:e4:8d:e7:c8:7c:d6:
                    68:2f:1c:d8:9c:52:02:a2:e2:0d:03:91:3b:a5:25:
                    3f:dd:e5:07:fb:cc:90:0d:0a:ae:9d:de:97:1a:0e:
                    5f:eb:c2:e8:8c:2b:2e:31:d6:f6:78:27:11:5d:19:
                    40:7a:cf:2d:3d:84:fc:e6:a4:74:50:ff:c0:da:05:
                    a1:10:ec:bc:97:5f:5e:04:ac:b1:a8:ac:97:e8:9e:
                    5d:51:e7:67:6f:b7:52:94:08:77:2f:ed:9d:69:f0:
                    a0:10:8d:b6:5e:f1:56:37:5d:38:58:df:6e:8d:21:
                    76:18:d1:de:cb:96:70:07:04:0b:a3:ca:bb:c2:b4:
                    51:50:44:7c:34:c9:95:9a:2c:01:62:aa:7a:80:01:
                    e7:69:22:c8:6f:f4:aa:6f:76:2b:44:9d:91:71:bc:
                    e0:39
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier: 
                E4:75:2E:ED:FD:F3:AB:7F:31:FB:B0:51:03:71:DE:FA:23:E5:2B:3A
            X509v3 Authority Key Identifier: 
                keyid:ED:8C:C8:07:27:B2:3D:8F:0D:16:31:B4:64:64:1B:DD:C8:F4:B3:F4
                DirName:/C=BD/ST=Dhaka/L=Dhaka/O=A2Z SERVERS LTD/OU=a2zservers.com/CN=a2zservers.com/name=BDEasyRSA/emailAddress=support@a2zservers.com
                serial:F5:5A:C5:96:7D:72:BC:53

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
    Signature Algorithm: sha256WithRSAEncryption
         81:56:cf:3e:d4:5b:6a:c8:2f:37:7c:31:ba:ae:2e:0c:20:4a:
         8a:bd:b7:35:cc:bc:47:c0:2d:b8:8c:8d:7a:9a:f2:ab:28:3d:
         02:7a:d6:06:b8:77:71:b5:a2:40:a2:6f:1a:34:02:40:a1:d5:
         e6:19:08:e7:08:fd:38:0b:fa:fc:b7:c7:22:9a:f3:f7:88:56:
         a4:69:a2:df:67:4a:80:90:d8:86:b3:db:43:3b:cb:37:86:f4:
         d9:31:7e:23:5d:9f:a3:82:14:df:eb:ae:7e:8d:76:a2:c8:29:
         ae:2e:f3:e9:db:1d:33:34:28:bb:78:a8:97:af:46:bf:a1:1d:
         ab:4f:2b:cf:bb:6c:64:24:13:a0:6d:4b:44:9d:05:92:fe:03:
         f7:29:be:f5:f6:fd:62:cc:11:e9:e4:f8:6c:88:43:0a:04:fd:
         0e:82:a2:bb:98:87:77:55:27:ae:12:30:3b:0a:37:52:fd:79:
         e1:00:00:7f:7f:51:1b:2f:b3:5b:f3:7d:0a:78:55:22:3b:cb:
         9a:ea:f6:f7:4e:f1:66:0c:b1:3e:5d:1e:45:3b:c5:03:3b:ae:
         8a:bc:4f:8e:40:da:a3:b4:54:f6:f7:ef:04:fe:95:38:ca:de:
         72:10:8a:f9:dd:a2:78:f0:a0:ae:48:84:f9:de:69:4d:05:66:
         fb:d2:bc:fd
-----BEGIN CERTIFICATE-----
MIIFaTCCBFGgAwIBAgIBATANBgkqhkiG9w0BAQsFADCBtDELMAkGA1UEBhMCQkQx
DjAMBgNVBAgTBURoYWthMQ4wDAYDVQQHEwVEaGFrYTEYMBYGA1UEChMPQTJaIFNF
UlZFUlMgTFREMRcwFQYDVQQLEw5hMnpzZXJ2ZXJzLmNvbTEXMBUGA1UEAxMOYTJ6
c2VydmVycy5jb20xEjAQBgNVBCkTCUJERWFzeVJTQTElMCMGCSqGSIb3DQEJARYW
c3VwcG9ydEBhMnpzZXJ2ZXJzLmNvbTAeFw0yMDA2MjYwNTQ1NTNaFw0zMDA2MjQw
NTQ1NTNaMIGxMQswCQYDVQQGEwJCRDEOMAwGA1UECBMFRGhha2ExDjAMBgNVBAcT
BURoYWthMRgwFgYDVQQKEw9BMlogU2VydmVycyBMdGQxFDASBgNVBAsTC0EyWiBT
ZXJ2ZXJzMRcwFQYDVQQDEw5hMnpzZXJ2ZXJzLmNvbTESMBAGA1UEKRMJQkRFYXN5
UlNBMSUwIwYJKoZIhvcNAQkBFhZzdXBwb3J0QGEyenNlcnZlcnMuY29tMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6jm4uOrMJ9SXDwh0UvYlGZXnOS3J
1Rs/EA6ylCnCzO5spkkVBuUkNUFHJkGuJfR3qFmThN74BaiTXQYhCXy2DdKiaJT9
CvZxzbFloAJaDAszClwGgsQf3nDNZsaCJ+HkPOTkjefIfNZoLxzYnFICouINA5E7
pSU/3eUH+8yQDQqund6XGg5f68LojCsuMdb2eCcRXRlAes8tPYT85qR0UP/A2gWh
EOy8l19eBKyxqKyX6J5dUednb7dSlAh3L+2dafCgEI22XvFWN104WN9ujSF2GNHe
y5ZwBwQLo8q7wrRRUER8NMmVmiwBYqp6gAHnaSLIb/Sqb3YrRJ2RcbzgOQIDAQAB
o4IBhTCCAYEwCQYDVR0TBAIwADARBglghkgBhvhCAQEEBAMCBkAwNAYJYIZIAYb4
QgENBCcWJUVhc3ktUlNBIEdlbmVyYXRlZCBTZXJ2ZXIgQ2VydGlmaWNhdGUwHQYD
VR0OBBYEFOR1Lu3986t/MfuwUQNx3voj5Ss6MIHpBgNVHSMEgeEwgd6AFO2MyAcn
sj2PDRYxtGRkG93I9LP0oYG6pIG3MIG0MQswCQYDVQQGEwJCRDEOMAwGA1UECBMF
RGhha2ExDjAMBgNVBAcTBURoYWthMRgwFgYDVQQKEw9BMlogU0VSVkVSUyBMVEQx
FzAVBgNVBAsTDmEyenNlcnZlcnMuY29tMRcwFQYDVQQDEw5hMnpzZXJ2ZXJzLmNv
bTESMBAGA1UEKRMJQkRFYXN5UlNBMSUwIwYJKoZIhvcNAQkBFhZzdXBwb3J0QGEy
enNlcnZlcnMuY29tggkA9VrFln1yvFMwEwYDVR0lBAwwCgYIKwYBBQUHAwEwCwYD
VR0PBAQDAgWgMA0GCSqGSIb3DQEBCwUAA4IBAQCBVs8+1FtqyC83fDG6ri4MIEqK
vbc1zLxHwC24jI16mvKrKD0CetYGuHdxtaJAom8aNAJAodXmGQjnCP04C/r8t8ci
mvP3iFakaaLfZ0qAkNiGs9tDO8s3hvTZMX4jXZ+jghTf665+jXaiyCmuLvPp2x0z
NCi7eKiXr0a/oR2rTyvPu2xkJBOgbUtEnQWS/gP3Kb719v1izBHp5PhsiEMKBP0O
gqK7mId3VSeuEjA7CjdS/XnhAAB/f1EbL7Nb830KeFUiO8ua6vb3TvFmDLE+XR5F
O8UDO66KvE+OQNqjtFT29+8E/pU4yt5yEIr53aJ48KCuSIT53mlNBWb70rz9
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.key
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDqObi46swn1JcP
CHRS9iUZlec5LcnVGz8QDrKUKcLM7mymSRUG5SQ1QUcmQa4l9HeoWZOE3vgFqJNd
BiEJfLYN0qJolP0K9nHNsWWgAloMCzMKXAaCxB/ecM1mxoIn4eQ85OSN58h81mgv
HNicUgKi4g0DkTulJT/d5Qf7zJANCq6d3pcaDl/rwuiMKy4x1vZ4JxFdGUB6zy09
hPzmpHRQ/8DaBaEQ7LyXX14ErLGorJfonl1R52dvt1KUCHcv7Z1p8KAQjbZe8VY3
XThY326NIXYY0d7LlnAHBAujyrvCtFFQRHw0yZWaLAFiqnqAAedpIshv9KpvditE
nZFxvOA5AgMBAAECggEBAMltalZcVcXLJT1gX+kYlT8zku2xWulRzSHaAek5ILVs
NTOrldGgLUs/IBjeUw2A94Znwl16AoGbP1+4baDjBw1MHy8hMZvD5IqoDGVWoGnL
F9HI4jCCyYVaLMo93KC/urBDh+ohcmEpYd9iR0XnoSzCib6Pn2OebRY+aGc6vIb5
C4gFjTZ8K+zSlTpd5Jx/B7wN4/IDuQxZIDkhNfqUj6OBnMIW/KvIUKGKmV0r4oXL
dacqoj5jbcRLl+SPqvMDcDqa2c37qWgctfalc8WQgooPBDkgMy38bZYsaTsa8k11
APdxIAYJaI8Yjy6fSZbuIp2SXfSLFhL+ofUSA1Xp+6ECgYEA+OChC1xj5rHvfUdQ
TyWSEywrD3HkYc12MEUWLF20aXF8lSYzuWRuOaz8DM45tMq0WkTFvQ0wd+xpEQfC
/9ZwQ0B/gb2P4T8iJFbjKDzgCleNfrAO6jz2h3qEKee6lC+0CX+37L4HFuPVqyDQ
OXfQZbIgbCUUCHDNi8d7rHclfPsCgYEA8O2/Gk/rXKjq2PyZ52UP7KhwSd48RNKM
NChIhMDZnKj//W1z8OQa0RHfXIPJ33ZOmaKunPT//foD48uuz9HrqLuwCRlfCfqJ
CQSUwp+YAoWDn0oSg/2jdAm16ziS6O0MpH4EL9zmHMeOaf4NmTIXlz8SXpYzeJ1c
ZmvtM+er6VsCgYEAioh/HFPRSBjDtnh7u5KuPP3Y+j/rYIV9xGCwdwGx6v/A2UTq
hcfhkzk3E+m3NWuf+J9PcmxlDlwKH/CyGrbCxqygTRe3fyolVxUGXN+F1jvmBx75
LmnA0Kjh6HGU6eejz6XIO3+LcrJfvWIGhfarifAdHBWHkSs5PxVLQjUQKQECgYEA
5IG5dO1D37heNbsvBWa2+dCv33+mTegcDgP+89otCwbG9Mhw5JKUVKLM5GQifY0p
81F2p2s/uNT+B3nRrU3+YyTQS3EC0OYMPr9XkFfpxsp3EgchFIrmElJ7dkNMIxth
mEnlErhCkB09F45bu2blNRAfDhMLcmRdlM7cRRR/2m0CgYBkOWtF+/+Wm5YJRpWo
K3lKVbcq9S24X3KcDUXg5s/Ijc8nzK1/MrMxJs4N5YPoD9UQhK+qVQYOhrgl5MFH
zP8bbWF17rlhP6BiqSnlF/DzSrgZAfySDkPIe/VkvrpYLqORuSzYP6jXRfz7Lpp8
7lVnzaO20Qkcj4RYWor59BE1LQ==
-----END PRIVATE KEY-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/dh2048.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAv4qM2EbvKNExWO4yYQCJ5d7/coGMSI2TVMm8LWNXlArbggOGEEMS
WiYaUDVThjgz2ct+HUPuLsHWN2k0OLe/p2rbS0AlQ08ZkOoL7U5aqlUb5YK+iHli
i3VugnELm1r8OJW2FIK3N/SeE6GaHtp71ZfAjkxNdwvxomjD0V/j7hNoV8cYWur8
cyYWBoMfQMkbTy2snGfBqQTcP3tnbBcPRTumTSFDyQ9c21syKggfxnT1r3CEQNlJ
mqSURBYIq+kv8MNjs7C8mQ9IpPZVkeBMNVGxPoQ9QasiotHdeWq4hGMxO3/3HGII
UBBXbEFgkbLoIxA9WUheh+nBVRGDoGgrewIBAg==
-----END DH PARAMETERS-----
EOF

chmod 755 /etc/openvpn/server.conf
chmod 755 /etc/openvpn/server2.conf
chmod 755 /etc/openvpn/server3.conf
chmod 755 /etc/openvpn/login/connect.sh
chmod 755 /etc/openvpn/login/disconnect.sh
chmod 755 /etc/openvpn/login/config.sh
chmod 755 /etc/openvpn/login/auth_vpn
touch /var/www/html/stat/status.txt
touch /var/www/html/stat/udpstatus.txt
touch /var/www/html/stat/udpstatus2.txt
touch /var/www/html/stat/ipp.txt
chmod 755 /var/www/html/stat/*
echo -e "\e[1;32m Done Creating Openvpn Files  \033[0m"
sleep 2

echo -e "\033[01;31m Configure Sysctl \033[0m"
echo 'fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.ip_forward=1
net.ipv4.icmp_echo_ignore_all = 1' >> /etc/sysctl.conf
echo '* soft nofile 512000
* hard nofile 512000' >> /etc/security/limits.conf
ulimit -n 512000

echo -e "\e[1;32m Done Configuring Sysctl  \033[0m"
sleep 2


echo -e "\033[01;31m Installing Stunnel \033[0m"
apt-get install stunnel4 -y > /dev/null 2>&1
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/bin/cat <<"EOM" > /etc/stunnel/stunnel.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAqBptpzCvwPqN1nZHVlY2du2D/MXdiALyvPJDp1G+TKW7+FUd
IZnW8udc6IVJZ2RZUtN/Edzvis0b2XXB9t3o6jR2CShn0uqmdTS14BjsNyrXBZRk
8tWDZawClIWKOkSq76UpTKVOlXhq+Uk1eoT/zB5qlgaZv5L0ye3c/n/eJUzqjOgV
Rez+5XaEyI5A4+83NxALcz10coMP4Qr4Mcp2NALPbXj4KKiIguemiaD9tgp7iQqs
GxTxWhfvMsbYL7FcJpGwWpv5GcxeCyR+L2t/67hC7dAvB5NSnLTioD1e2qu0Zcd5
dhII8wr/pgC+7Y2GjTtITnHIogx3Q2LzCjF4owIDAQABAoIBAQCNfcEx6l7kdYAR
NXkSCHrLW1uu1PSD2MdrlhavrLQaW519hlaAw7YSuf6PkDCan/I3LuFTrbzJ/Z4l
SWK7YUj8aK+5QZMyCmOVX4p+Vzvrq1lUzvSxGFoCp+d8D3KrXMTr9P5wDuu4D6Uq
sh4bQ/ryWd+o62FZyF3V4SoT5Jicl2U1O3xC20nbZJMglXzuhQRaI3ZnuG4d0zHX
Eonp7wbcoKbDFJyrtSDhdwS9vylm5oo02+pgUZ1ELXglHw1ezuHekSOhIJBVdrER
3Ch9mJ0fqGQKofD1PaIGpFviBF3YJEskiVSpAAiZ5pmwFvzWxqAnlYi59nlHSvwB
tO7n51ChAoGBANw1uwTGhnU30Xgbx0KY+3J8kGHSJZeRjhZwt4646WxDT7EkAqjg
TovR80yNf7vVqwDt07j1Q5DNo7MVGbvyXwPaMsAXiYbBppaGRDQtp6UylIv+tmDo
DhYEbwQSQtGsdADjvtiBqt2tYdFW+omB88ZCfEuS7va5wcneP/Xq2UTrAoGBAMNs
snuSAzXhJaxyE6AvYFoFJxWW0H8FPhQ5g+xS+jBNpj9SbARzn7yZFRGXy2xzmbK+
wQA3IN40upIIy8ZiTIppvi/b/O8eaQqwQzsevzENMCKNGEjsrBpQ51wwzq1ix42Y
8Fn1AMsMaitC1YymvLOvtuIA29OBQ1a1pslrUI0pAoGAGGhcMktO2+8z6HwrudX7
CNWFq1H/mK0pcpNLxSX5uWY8jwXOxakXC6hZr0J/xfII4jF6JiYJNyOT4WWVVJ+o
qGSm+2Ogeq88J7L6HE5zJnxUuq+gx1zxMr+LDoh3n4Xd1btoi9bTeX6eOPXLDzK4
MmFsJXRDyFUOhbF8pWVCb8ECgYBfYEBnoKZieGS7md1MM3MR3CvsFHPjWjqnAj8J
aqHiSzNU+jPvpEKUeB3ZPT0xy+V6YDCvmzg2WoOn3BUf2D/E2cDReMskJLJdXhMh
2mqzVN1mL3hntuJz4YJY8xUbd/cuezLqpHFjp8Z1IKQ6hfHYvGxENukSe6bSvcsN
yItCqQKBgG/nF1FTFjM97x049sP7iAlxhRxg2Yi6qthvmmFo8xBnLO66CG9PEC3G
1MYWIzB6YtJG89NFFIGog/G2Cz95JjJDLDUOO41K/z1pBnArP54jvxx+iDuZlFMB
mWorw0zwnwbBhrQ3hH+YsQ5uI9eg7RN+8ZbmoXUweeUlzpsiaMaw
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIEHTCCAwWgAwIBAgIJAIciQafGgIDvMA0GCSqGSIb3DQEBBQUAMIGkMQswCQYD
VQQGEwJCRDEOMAwGA1UECAwFRGhha2ExDjAMBgNVBAcMBURoYWthMRgwFgYDVQQK
DA9BMlogU0VSVkVSUyBMVEQxFzAVBgNVBAsMDmEyenNlcnZlcnMuY29tMRswGQYD
VQQDDBJ3d3cuYTJ6c2VydmVycy5jb20xJTAjBgkqhkiG9w0BCQEWFnN1cHBvcnRA
YTJ6c2VydmVycy5jb20wHhcNMjAwNjI3MDQzODU5WhcNNDgwMjE2MDQzODU5WjCB
pDELMAkGA1UEBhMCQkQxDjAMBgNVBAgMBURoYWthMQ4wDAYDVQQHDAVEaGFrYTEY
MBYGA1UECgwPQTJaIFNFUlZFUlMgTFREMRcwFQYDVQQLDA5hMnpzZXJ2ZXJzLmNv
bTEbMBkGA1UEAwwSd3d3LmEyenNlcnZlcnMuY29tMSUwIwYJKoZIhvcNAQkBFhZz
dXBwb3J0QGEyenNlcnZlcnMuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAqBptpzCvwPqN1nZHVlY2du2D/MXdiALyvPJDp1G+TKW7+FUdIZnW8udc
6IVJZ2RZUtN/Edzvis0b2XXB9t3o6jR2CShn0uqmdTS14BjsNyrXBZRk8tWDZawC
lIWKOkSq76UpTKVOlXhq+Uk1eoT/zB5qlgaZv5L0ye3c/n/eJUzqjOgVRez+5XaE
yI5A4+83NxALcz10coMP4Qr4Mcp2NALPbXj4KKiIguemiaD9tgp7iQqsGxTxWhfv
MsbYL7FcJpGwWpv5GcxeCyR+L2t/67hC7dAvB5NSnLTioD1e2qu0Zcd5dhII8wr/
pgC+7Y2GjTtITnHIogx3Q2LzCjF4owIDAQABo1AwTjAdBgNVHQ4EFgQUgKaZRa2J
NYxKkeTXnL1NQY5ueqowHwYDVR0jBBgwFoAUgKaZRa2JNYxKkeTXnL1NQY5ueqow
DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOCAQEAX0kciouCCPcK3Wq9UPUY
DrrkOD3VC469rMGZFxw9sWRO/ZYomiF391lbVJ1JYtRNQBF01YaxdSGDHYzpTfbg
OXiuMo/s97wP67yzXbmFU9pU9767jJVDKwQXzAYmK668lloRRCzv7berxNXTOm5c
xoa97gnLUiGMU4nQS2G4rAsF56ddk3WnuXxH/3hIVjSSIdq9eg4+fsDgxVnH2ehN
DLkRM+jNpiLRpm9txGOTnyFAikNGOboNSDYNx9J/uM5uoPzJDOQAoW+gV7pTut3b
I//hEv0+/RO5PEfXQkK25mpOcXgJNmxJ5UuUvm7vm5j72hzF5lT3MFYtIDwZ7Pte
+A==
-----END CERTIFICATE-----
EOM


echo 'cert=/etc/stunnel/stunnel.pem
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no
[squid]
accept = 8000
connect = 127.0.0.1:8080

[openvpn]
accept = 443
connect = 127.0.0.1:1194'| sudo tee /etc/stunnel/stunnel.conf
echo -e "\e[1;32m Done Installing Stunnel  \033[0m"
sleep 2

echo -e "\033[01;31m Configuring Iptables & Fail2ban \033[0m"
sudo add-apt-repository ppa:linrunner/tlp -y > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1
sudo apt-get install tlp tlp-rdw -y > /dev/null 2>&1
sudo tlp start > /dev/null 2>&1

update-rc.d squid3 enable
update-rc.d openvpn enable
update-rc.d apache2 enable
update-rc.d cron enable
update-rc.d stunnel4 enable
update-rc.d fail2ban enable
update-rc.d tlp enable

iptables -F; iptables -X; iptables -Z
iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source "$(curl ipecho.net/plain)"
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source "$(curl ipecho.net/plain)"
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source "$(curl ipecho.net/plain)"
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source "$(curl ipecho.net/plain)"
sysctl -p

sudo usermod -a -G www-data root
sudo chgrp -R www-data /var/www
sudo chmod -R g+w /var/www

touch /usr/local/sbin/reboot.sh
echo 'reboot
' > /usr/local/sbin/reboot.sh
touch /usr/local/sbin/ssl.sh
echo 'service stunnel4 start
' > /usr/local/sbin/ssl.sh
/bin/cat <<"EOM" >/usr/local/sbin/ram.sh
sudo sync; echo 3 > /proc/sys/vm/drop_caches
swapoff -a && swapon -a
echo '#' > /var/log/haproxy.log
echo "Ram Cleaned!"
EOM

chmod +x /usr/local/sbin/ram.sh
chmod +x /usr/local/sbin/reboot.sh
chmod +x /usr/local/sbin/ssl.sh

(crontab -l 2>/dev/null || true; echo "#
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 4 * * * /usr/local/sbin/reboot.sh
*/15 * * * * /usr/local/sbin/ssl.sh
* * * * * /usr/local/sbin/ram.sh") | crontab -

service cron restart

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime  = 600/bantime  = 3600/g' /etc/fail2ban/jail.local
sed -i 's/maxretry = 10/maxretry = 3/g' /etc/fail2ban/jail.local
sed -i 's/destemail = '.*'/destemail = a2zvpn@gmail.com/g' /etc/fail2ban/jail.local

sudo timedatectl set-timezone Asia/Dhaka
timedatectl

sudo apt install debconf-utils -y > /dev/null 2>&1

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y > /dev/null 2>&1

iptables-save > /etc/iptables/rules.v4 
ip6tables-save > /etc/iptables/rules.v6
echo -e "\e[1;32m Configuring Done \033[0m"
sleep 2

/bin/cat <<"EOM" >/var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Design by Saudi Connect</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="stylesheet" href="https://bootswatch.com/4/slate/bootstrap.min.css" media="screen">
<link href="https://fonts.googleapis.com/css?family=Press+Start+2P" rel="stylesheet">
<style>
    body {
     font-family: "Press Start 2P", cursive;    
    }
    .fn-color {
        color: #ff00ff;
        background-image: -webkit-linear-gradient(92deg, #f35626, #feab3a);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        -webkit-animation: hue 5s infinite linear;
    }

    @-webkit-keyframes hue {
      from {
        -webkit-filter: hue-rotate(0deg);
      }
      to {
        -webkit-filter: hue-rotate(-360deg);
      }
    }
</style>
</head>
<body>
<div class="container" style="padding-top: 50px">
<div class="jumbotron">
<h1 class="display-3 text-center fn-color">FIRENET SCRIPTZ</h1>
<h4 class="text-center fn-color">Follow Us</h4>
<p class="text-center">https://facebook.com/alaminbd17</p>
</div>
</div>
</body>
</html>
EOM

apt-get install squid -y
rm -f /etc/squid/squid.*
cat <<'SquidProxy' > /etc/squid/squid.conf
acl VPN dst IP-ADDRESS/32
http_access allow VPN
http_access deny all
http_port 0.0.0.0:8080
http_port 0.0.0.0:3128
acl bonv src 0.0.0.0/0.0.0.0
no_cache deny bonv
dns_nameservers 1.1.1.1 1.0.0.1
visible_hostname localhost
SquidProxy
sed -i "s|IP-ADDRESS|$MYIP|g" /etc/squid/squid.conf

echo -e "\033[01;31m Starting Services \033[0m"
service openvpn start
service squid start
service apache2 start
service fail2ban start
service stunnel4 start

sed -i 's/#ForwardToWall=yes/ForwardToWall=no/g' /etc/systemd/journald.conf

sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get clean > /dev/null 2>&1
history -c
cd /root || exit
rm -f /root/installer.sh
echo -e "\e[1;32m Installing Done \033[0m"
echo 'root:@@F1r3n3t' | sudo chpasswd
reboot
