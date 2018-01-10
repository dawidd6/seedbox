#!/bin/bash

USER=root
HOME_DIR=/root
RUTORRENT_USER=user
RUTORRENT_PASS=pass

apt-get update
apt-get install -yy screen rtorrent lighttpd php-cgi openssl wget

wget http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz -P /tmp
tar -xz -C /var/www/html -f /tmp/rutorrent-3.6.tar.gz
rm /tmp/rutorrent-3.6.tar.gz
printf "include \"seedbox.conf\"\n" >> /etc/lighttpd/lighttpd.conf
printf "$RUTORRENT_USER:$(openssl passwd -crypt $RUTORRENT_PASS)\n" >> /var/www/html/rutorrent/.htpasswd
mkdir -p /run/lighttpd
chown -R www-data:www-data /run/lighttpd

cp files/.rtorrent.rc "$HOME_DIR"
cp files/seedbox.conf /etc/lighttpd
cp files/rtorrent.service /etc/systemd/system

sed -i -e "s@localhost/htdocs@html@" /etc/lighttpd/seedbox.conf
sed -i -e "s@root@$USER@" /etc/systemd/system/rtorrent.service

systemctl enable lighttpd
systemctl enable rtorrent
