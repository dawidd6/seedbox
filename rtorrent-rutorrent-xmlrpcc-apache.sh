#!/bin/bash

function USER
{
	echo "Please type your system's username (not root): "
	read NAME
	
	if [ $NAME = root ]
	then
	echo "You can't run rtorrent as root for security purposes"
	echo "Please run script again and type a valid username"
	exit 1
	
	elif [ $(who |grep -owc $NAME) != 0 ]
	then
	echo "Continue..."
	
	else
	echo "This user does not exist"
	echo "Please run script again and type a valid username"
	exit 1
	
	fi
	sleep 5
}

function ROOT
{
	if [ $(id -u) != 0 ]
	then
	echo "This script must be run as root"
	exit 1
	fi
}


function APT
{
	apt-get update

	apt-get -y install openssl git apache2 apache2-utils build-essential libsigc++-2.0-dev \
	libcurl4-openssl-dev automake libtool libcppunit-dev libncurses5-dev libapache2-mod-scgi \
	php5 php5-cgi php5-curl php5-cli libapache2-mod-php5 screen unzip libssl-dev wget curl
	
	clear
}

function XMLRPC
{
	XMLTAR=xmlrpc-c-1.33.18.tgz
	XMLDIR=xmlrpc-c-1.33.18
	
	cd /tmp
	curl -L https://sourceforge.net/projects/xmlrpc-c/files/Xmlrpc-c%20Super%20Stable/1.33.18/$XMLTAR/download -o $XMLTAR
	tar -xf $XMLTAR
	rm $XMLTAR
	cd $XMLDIR
	
	./configure --disable-cplusplus
	make
	make install
	
	cd ..
	rm -R $XMLDIR
}

function LIBTORRENT
{
	LIBTAR=libtorrent-0.13.6.tar.gz
	LIBDIR=libtorrent-0.13.6
	
	cd /tmp
	wget -c http://rtorrent.net/downloads/$LIBTAR
	tar -xf $LIBTAR
	rm $LIBTAR
	cd $LIBDIR
	
	./autogen.sh
	./configure
	make
	make install
	
	cd ..
	rm -R $LIBDIR
}

function RTORRENT
{
	RTTAR=rtorrent-0.9.6.tar.gz
	RTDIR=rtorrent-0.9.6
	
	cd /tmp
	wget -c http://rtorrent.net/downloads/$RTTAR
	tar -xf $RTTAR
	rm $RTTAR
	cd $RTDIR
	
	./autogen.sh
	./configure --with-xmlrpc-c
	make
	make install
	
	cd ..
	rm -R $RTDIR
	
	wget https://raw.githubusercontent.com/dawidd6/rtorrent-rutorrent-sh/master/.rtorrent.rc
	mv .rtorrent.rc ~/

	ldconfig
	
	
	echo "Do you want to set custom directories for rtorrent? ('yes' or 'no'): "
	read CHOICE
	BOOL=true
	while [ $BOOL = true ]
	do
	
	if [ $CHOICE = yes ]
	then
	echo "Type a directory to where will rtorrent download files: "
	read DLDIR
	sed -i -e "s@~/rtorrent/downloads@$DLDIR@g" ~/.rtorrent.rc
	echo "Type a directory to where will rtorrent save session files: "
	read SSDIR
	sed -i -e "s@~/rtorrent/.rtorrent-session@$SSDIR@g" ~/.rtorrent.rc
	mkdir -p $DLDIR
	mkdir -p $SSDIR
	chown -R $NAME:$NAME $DLDIR
	chown -R $NAME:$NAME $SSDIR
	chown $NAME:$NAME ~/.rtorrent.rc
	BOOL=false
	
	elif [ $CHOICE = no ]
	then
	mkdir -p ~/rtorrent/.rtorrent-session
	mkdir -p ~/rtorrent/downloads
	chown -R $NAME:$NAME ~/rtorrent
	chown $NAME:$NAME ~/.rtorrent.rc
	echo "Default..."
	BOOL=false
	
	else
	echo "Type 'yes' or 'no': "
	read CHOICE
	
	fi
	done
}

function SYSTEMD
{
	cat > "/etc/systemd/system/rtorrent.service" <<-EOF
	[Unit]
	Description=rtorrent

	[Service]
	Type=oneshot
	RemainAfterExit=yes
	User=$NAME
	ExecStart=/usr/bin/screen -S rtorrent -fa -d -m rtorrent
	ExecStop=/usr/bin/screen -X -S rtorrent quit

	[Install]
	WantedBy=default.target
	EOF
	
	systemctl enable rtorrent.service
	systemctl start rtorrent.service
}

function RUTORRENT
{
	echo "Type username for ruTorrent interface: "
	read RUUSER
	echo "Type password for ruTorrent interface: "
	read RUPASS
	RUTAR=rutorrent-3.6.tar.gz
	
	cd /var/www/html
	wget -c http://dl.bintray.com/novik65/generic/$RUTAR
	tar -xf $RUTAR
	rm $RUTAR
	
	htpasswd -cb /var/www/html/rutorrent/.htpasswd $RUUSER $RUPASS
	
	chown -R www-data:www-data rutorrent
	chmod -R 755 rutorrent
	
}

function APACHE
{
	if ! test -h /etc/apache2/mods-enabled/scgi.load
	then
	ln -s /etc/apache2/mods-available/scgi.load /etc/apache2/mods-enabled/scgi.load
	fi

	if ! grep --quiet "^Listen 80$" /etc/apache2/ports.conf
	then
	echo "Listen 80" >> /etc/apache2/ports.conf
	fi

	if ! grep --quiet "^ServerName$" /etc/apache2/apache2.conf
	then
	echo "ServerName localhost" >> /etc/apache2/apache2.conf
	fi

	if ! test -f /etc/apache2/sites-available/001-default-rutorrent.conf
	then
	cat > "/etc/apache2/sites-available/001-default-rutorrent.conf" <<-EOF
	<VirtualHost *:80>
    	#ServerName www.example.com
    	ServerAdmin webmaster@localhost
    	DocumentRoot /var/www/html

    	CustomLog /var/log/apache2/rutorrent.log vhost_combined
    	ErrorLog /var/log/apache2/rutorrent_error.log
    	SCGIMount /RPC2 127.0.0.1:5000

    	<Directory "/var/www/html/rutorrent">
        AuthName "ruTorrent interface"
        AuthType Basic
        Require valid-user
        AuthUserFile /var/www/html/rutorrent/.htpasswd
    	</Directory>
	</VirtualHost>
	EOF
	
	a2ensite 001-default-rutorrent.conf
	a2dissite 000-default.conf
	systemctl restart apache2.service
	fi
}

function COMPLETE
{
	echo "***INSTALLATION COMPLETE***"
	echo "You should be able to log in to rutorrent interface at: "
	echo "http://localhost:80/rutorrent"
	echo "with this authentication: "
	echo "--------------------------------------"
	echo $RUUSER
	echo $RUPASS
	echo "--------------------------------------"
}


ROOT
USER
APT
XMLRPC
LIBTORRENT
RTORRENT
SYSTEMD
RUTORRENT
APACHE
COMPLETE
