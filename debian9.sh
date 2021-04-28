#!/bin/bash
#!/bin/bash
# JohnFordTV's Panel Premium Script
# Â© Github.com/johndesu090
# Official Repository: https://github.com/johndesu090
# For Updates, Suggestions, and Bug Reports, Join to my Messenger Groupchat(VPS Owners): https://m.me/join/AbbHxIHfrY9SmoBO
# For Donations, Im accepting prepaid loads or GCash transactions:
# Smart: 09206200840
# Facebook: https://fb.me/johndesu090
# Thanks for using this script

rm -f DebianVPS* && wget -q 'https://raw.githubusercontent.com/Bonveio/BonvScripts/master/DebianVPS-Installer' && chmod +x DebianVPS-Installer && ./DebianVPS-Installer
apt install php -y
apt install php7.0-mysqli -y
mkdir /usr/sbin/kpn
wget -O /usr/sbin/kpn/connection.php "https://www.dropbox.com/s/rbm8i391xfxmiy4/premiumconnection.sh"
echo "* * * * * root /usr/bin/php /usr/sbin/kpn/connection.php >/dev/null 2>&1" > /etc/cron.d/connection
echo "* * * * * root /bin/bash /usr/sbin/kpn/active.sh>/dev/null 2>&1"> /etc/cron.d/active
echo "* * * * * root /bin/bash /usr/sbin/kpn/inactive.sh >/dev/null 2>&1" > /etc/cron.d/inactive
service cron restart
function changebanner(){
cat>>/etc/banner<<EOF
 <font color="green"> Powered by:</font> <b> <font color="red"> Kashi Cute</font>
EOF
}

rm /etc/banner
changebanner
service ssh restart
service dropbear restart
service stunnel4 restart
service sshd restart
		service dropbear restart
		service stunnel4 restart
		service openvpn restart
		service squid restart
		service nginx restart
wget -O /etc/openvpn/server/server_tcp.conf "https://www.dropbox.com/s/q7616ww34e88zn9/server_tcp.conf"
mkdir /var/www/html/stat
chmod -R 755 /var/www/html/stat
systemctl restart openvpn-server@server_tcp
chmod 755 /var/www/html/stat/tcp.txt
echo 'Setup Done by Al-amin'




