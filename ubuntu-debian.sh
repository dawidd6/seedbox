#!/bin/bash

#Variables
#########################################################
NAME=
BOOL=true
CHOICE=

RTORRENT_DOWNLOAD_DIR=
RTORRENT_SESSION_DIR=

XMLRPCC_TARBALL=xmlrpc-c-1.33.18.tgz
XMLRPCC_DIR=xmlrpc-c-1.33.18

LIBTORRENT_TARBALL=libtorrent-0.13.6.tar.gz
LIBTORRENT_DIR=libtorrent-0.13.6

RTORRENT_TARBALL=rtorrent-0.9.6.tar.gz
RTORRENT_DIR=rtorrent-0.9.6

RUTORRENT_TARBALL=rutorrent-3.6.tar.gz

RUTORRENT_USER=
RUTORRENT_PASS=

WEBSERVER=0
#########################################################

#Functions
#########################################################
#function GREETINGS
#function GET_USERNAME
#function CHECK_ROOT
#function GET_WEBSERVER
#function COMPLETE
#function RTORRENT_CONFIGURE
#function DEPENDENCIES
#function DOWNLOAD_STUFF
#function XMLRPCC_COMPILE
#function LIBTORRENT_COMPILE
#function RTORRENT_COMPILE
#function SYSTEMD_SERVICE
#function RUTORRENT
#function WEBSERVER_CONFIGURE
#########################################################

#Greetings
#########################################################
function GREETINGS
{
	 echo -e "\n\e[1;36mVersions of components to be installed:\e[0m"
	 echo "-----------------------------------------------------"
	 echo -e "\e[1;32mxmlrpc-c\e[0m - \e[1;31m1.33.18\e[0m"
	 echo -e "\e[1;32mlibtorrent\e[0m - \e[1;31m0.13.6\e[0m"
	 echo -e "\e[1;32mrtorrent\e[0m - \e[1;31m0.9.6\e[0m"
	 echo -e "\e[1;32mrutorrent\e[0m - \e[1;31m3.6\e[0m"
	 echo "-----------------------------------------------------"
	 echo -e "\nScript has been assembled by \e[1mdawidd6\e[0m\n"
}
#########################################################

#Various Shit
#########################################################
function CHECK_ROOT
{
	if [ $(id -u) != 0 ]
	then
	echo "This script must be run as root"
	exit 1
	fi
}

function GET_USERNAME
{
	echo "Please type your system's username (not root): "
	read NAME
	
	if [ $NAME = root ]
	then
	echo "You can't run rtorrent as root for security purposes"
	echo "Please run script again and type a valid username"
	exit 1
	
	elif [ $(printf '%s\n' "${SUDO_USER:-$USER}") = $NAME ]
	then
	echo "Continuing..."
	
	else
	echo "This user does not exist"
	echo "Please run script again and type a valid username"
	exit 1
	
	fi
	sleep 3
}

function GET_WEBSERVER
{
	echo "Please type which webserver would you use ('1' or '2'):"
	echo "1) Apache"
	echo "2) Lighttpd"
	
	until [ $WEBSERVER = 1 ] || [ $WEBSERVER = 2 ]
	do
	read WEBSERVER
	if [ $WEBSERVER != 1 ] && [ $WEBSERVER != 2 ]
	then
	echo "Please type a valid number"
	fi
	done
}
#########################################################

#Dependencies
#########################################################
function DEPENDENCIES
{
	apt-get update
	
	if [ $WEBSERVER = 1 ]
	then
	apt-get -y install apache2 apache2-utils libapache2-mod-scgi libapache2-mod-php5
	elif [ $WEBSERVER = 2 ]
	then
	apt-get -y install lighttpd
	fi
	
	apt-get -y install openssl git build-essential libsigc++-2.0-dev \
	libcurl4-openssl-dev automake libtool libcppunit-dev libncurses5-dev \
	php5 php5-cgi php5-curl php5-cli screen unzip libssl-dev wget curl
}
#########################################################

#Download
#########################################################
function DOWNLOAD_STUFF
{
	cd /tmp
	curl -L https://sourceforge.net/projects/xmlrpc-c/files/Xmlrpc-c%20Super%20Stable/1.33.18/$XMLRPCC_TARBALL/download -o $XMLRPCC_TARBALL
	wget -c http://rtorrent.net/downloads/$LIBTORRENT_TARBALL
	wget -c http://rtorrent.net/downloads/$RTORRENT_TARBALL
	wget -c http://dl.bintray.com/novik65/generic/$RUTORRENT_TARBALL
	wget -c http://raw.githubusercontent.com/dawidd6/seedbox/master/files/.rtorrent.rc -P /home/$NAME	
}
#########################################################

#Compile
#########################################################
function XMLRPCC_COMPILE
{
	cd /tmp
	tar -xf $XMLRPCC_TARBALL
	rm $XMLRPCC_TARBALL
	cd $XMLRPCC_DIR
	
	./configure --disable-cplusplus
	make
	make install
	
	cd ..
	rm -R $XMLRPCC_DIR
}

function LIBTORRENT_COMPILE
{
	cd /tmp
	tar -xf $LIBTORRENT_TARBALL
	rm $LIBTORRENT_TARBALL
	cd $LIBTORRENT_DIR
	
	./autogen.sh
	./configure
	make
	make install
	
	cd ..
	rm -R $LIBTORRENT_DIR
}

function RTORRENT_COMPILE
{
	cd /tmp
	tar -xf $RTORRENT_TARBALL
	rm $RTORRENT_TARBALL
	cd $RTORRENT_DIR
	
	./autogen.sh
	./configure --with-xmlrpc-c
	make
	make install
	
	cd ..
	rm -R $RTORRENT_DIR

	ldconfig
}
#########################################################

#Rtorrent Configuration
#########################################################
function RTORRENT_CONFIGURE
{
	echo -e "\nDefault directory for downloads is: ~/rtorrent/downloads"
	echo -e "Default directory for session files is: ~/rtorrent/.rtorrent-session\n"
	echo "Do you want to set custom directories for rtorrent? ('yes' or 'no'): "
	read CHOICE
	
	while [ $BOOL = true ]
	do
	
	if [ $CHOICE = yes ]
	then
	echo "Type a directory to where will rtorrent download files: "
	read RTORRENT_DOWNLOAD_DIR
	sed -i -e "s@~/rtorrent/downloads@$RTORRENT_DOWNLOAD_DIR@g" /home/$NAME/.rtorrent.rc
	echo "Type a directory to where will rtorrent save session files: "
	read RTORRENT_SESSION_DIR
	sed -i -e "s@~/rtorrent/.rtorrent-session@$RTORRENT_SESSION_DIR@g" /home/$NAME/.rtorrent.rc
	mkdir -p $RTORRENT_DOWNLOAD_DIR
	mkdir -p $RTORRENT_SESSION_DIR
	chown -R $NAME:$NAME $RTORRENT_DOWNLOAD_DIR
	chown -R $NAME:$NAME $RTORRENT_SESSION_DIR
	BOOL=false
	
	elif [ $CHOICE = no ]
	then
	mkdir -p /home/$NAME/rtorrent/.rtorrent-session
	mkdir -p /home/$NAME/rtorrent/downloads
	chown -R $NAME:$NAME /home/$NAME/rtorrent/.rtorrent-session
	chown -R $NAME:$NAME /home/$NAME/rtorrent/downloads
	echo "Default..."
	BOOL=false
	sleep 3
	
	else
	echo "Type 'yes' or 'no': "
	read CHOICE
	
	fi
	done
	
	chown $NAME:$NAME /home/$NAME/.rtorrent.rc
}
#########################################################

#Service
#########################################################
function SYSTEMD_SERVICE
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
	
	systemctl start rtorrent.service
	systemctl enable rtorrent.service
}
#########################################################

#Rutorrent
#########################################################
function RUTORRENT
{
	echo "Type username for ruTorrent interface: "
	read RUTORRENT_USER
	echo "Type password for ruTorrent interface: "
	read RUTORRENT_PASS

	mv /tmp/$RUTORRENT_TARBALL /var/www/html
	cd /var/www/html
	tar -xf $RUTORRENT_TARBALL
	chown -R www-data:www-data rutorrent
	chmod -R 755 rutorrent
	
	rm $RUTORRENT_TARBALL
	
}
#########################################################

#Webservers
#########################################################
function WEBSERVER_CONFIGURE
{
	if [ $WEBSERVER = 1 ]
	then
		htpasswd -cb /var/www/html/rutorrent/.htpasswd $RUTORRENT_USER $RUTORRENT_PASS
	
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
		systemctl enable apache2.service
		fi
	
	elif [ $WEBSERVER = 2 ]
	then
		printf "$RUTORRENT_USER:$(openssl passwd -crypt $RUTORRENT_PASS)\n" >> /var/www/html/rutorrent/.htpasswd
	
		if ! grep --quiet "mod_auth" /etc/lighttpd/lighttpd.conf
		then
		echo 'server.modules += ( "mod_auth" )' >> /etc/lighttpd/lighttpd.conf
		fi
	
		if ! grep --quiet "mod_scgi" /etc/lighttpd/lighttpd.conf
		then
		echo 'server.modules += ( "mod_scgi" )' >> /etc/lighttpd/lighttpd.conf
		fi
	
		if ! grep --quiet "mod_fcgi" /etc/lighttpd/lighttpd.conf
		then
		echo 'server.modules += ( "mod_fastcgi" )' >> /etc/lighttpd/lighttpd.conf
		fi
	
		if ! grep --quiet "cgi.fix_pathinfo=1" /etc/php5/cgi/php.ini
		then
		echo "cgi.fix_pathinfo=1" >> /etc/php5/cgi/php.ini
		fi
	
		if ! grep --quiet "fastcgi.server" /etc/lighttpd/lighttpd.conf
		then
		cat >> "/etc/lighttpd/lighttpd.conf" <<-EOF
		fastcgi.server = ( ".php" => ((
		"bin-path" => "/usr/bin/php5-cgi",
		"socket" => "/tmp/php.socket"
		)))
		EOF
		fi
	
		if ! grep --quiet "auth.backend.htpasswd.userfile" /etc/lighttpd/lighttpd.conf
		then
		cat >> "/etc/lighttpd/lighttpd.conf" <<-EOF
		auth.backend = "htpasswd"
		auth.backend.htpasswd.userfile = "/var/www/html/rutorrent/.htpasswd"
		auth.require = ( "/rutorrent" =>
	    	(
	    	"method"  => "basic",
	    	"realm"   => "ruTorrent interface",
	    	"require" => "valid-user"
	    	),
		)
		EOF
		fi
	
		if ! grep --quiet "scgi.server" /etc/lighttpd/lighttpd.conf
		then
		cat >> "/etc/lighttpd/lighttpd.conf" <<-EOF
		scgi.server = (
		"/RPC2" =>
		( "127.0.0.1" =>
		(                
		"host" => "127.0.0.1",
		"port" => 5000,
		"check-local" => "disable"
	       	)
		)
		)
		EOF
		fi
	
		systemctl restart lighttpd
		systemctl enable lighttpd
	fi
}
#########################################################

#Complete
#########################################################
function COMPLETE
{
	echo -e "\n***INSTALLATION COMPLETED***"
	echo "You should be able after reboot to log in to rutorrent interface at: "
	echo "http://localhost:80/rutorrent"
	echo "with this authentication: "
	echo "-----------------------------------------------------"
	echo $RUTORRENT_USER
	echo $RUTORRENT_PASS
	echo "-----------------------------------------------------"
	echo "XMLRPC-C is working on /RPC2 address"
}
#########################################################

#Main
#########################################################
CHECK_ROOT
GREETINGS
GET_USERNAME
GET_WEBSERVER
DEPENDENCIES
DOWNLOAD_STUFF
XMLRPCC_COMPILE
LIBTORRENT_COMPILE
RTORRENT_COMPILE
SYSTEMD_SERVICE
RUTORRENT
WEBSERVER_CONFIGURE
RTORRENT_CONFIGURE
COMPLETE
#########################################################
