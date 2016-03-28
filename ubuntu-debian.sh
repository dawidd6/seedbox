#!/bin/bash

source include.sh

#Dependencies
#########################################################
DEPENDENCIES()
{
	apt-get update
	
	if [ $WEBSERVER = 1 ]
	then
	apt-get -y install apache2 apache2-utils libapache2-mod-scgi libapache2-mod-php5
	elif [ $WEBSERVER = 2 ]
	then
	apt-get -y install lighttpd
	fi
	
	apt-get -y install openssl build-essential libsigc++-2.0-dev libxmlrpc-core-c3-dev\
	libcurl4-openssl-dev automake libtool libcppunit-dev libncurses5-dev \
	php5 php5-cgi php5-curl php5-cli screen unzip libssl-dev wget curl
}
#########################################################

#Download
#########################################################
DOWNLOAD_STUFF()
{
	cd /tmp
	wget -c http://rtorrent.net/downloads/$LIBTORRENT_TARBALL
	wget -c http://rtorrent.net/downloads/$RTORRENT_TARBALL
	wget -c http://dl.bintray.com/novik65/generic/$RUTORRENT_TARBALL
}
#########################################################

#Compile
#########################################################
LIBTORRENT_COMPILE()
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

RTORRENT_COMPILE()
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

#Service
#########################################################
SYSTEMD_SERVICE()
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
RUTORRENT()
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
WEBSERVER_CONFIGURE()
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

#Uninstall
#########################################################
UNINSTALL()
{
	cd /tmp
	
	wget -c http://rtorrent.net/downloads/$LIBTORRENT_TARBALL
	wget -c http://rtorrent.net/downloads/$RTORRENT_TARBALL

	tar -xf $RTORRENT_TARBALL
	rm $RTORRENT_TARBALL
	cd $RTORRENT_DIR
	./autogen.sh
	./configure --with-xmlrpc-c
	make uninstall
	cd ..
	rm -R $RTORRENT_DIR

	tar -xf $LIBTORRENT_TARBALL
	rm $LIBTORRENT_TARBALL
	cd $LIBTORRENT_DIR
	./autogen.sh
	./configure
	make uninstall
	cd ..
	rm -R $LIBTORRENT_DIR

	ldconfig

	
	apt-get purge openssl libsigc++-2.0-dev \
	libcurl4-openssl-dev automake libcppunit-dev libncurses5-dev \
	php5 php5-cgi php5-curl php5-cli screen libssl-dev libxmlrpc-core-c3-dev

	if dpkg -l|grep -q apache2
	then
	apt-get purge apache2 apache2-utils libapache2-mod-scgi libapache2-mod-php5
	elif dpkg -l|grep -q lighttpd
	then
	apt-get purge lighttpd
	fi

	RTORRENT_DOWNLOAD_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^directory/ {print $3;}')"
	RTORRENT_SESSION_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^session/ {print $3;}')"

	rm -R "$RTORRENT_DOWNLOAD_DIR"
	rm -R "$RTORRENT_SESSION_DIR"
	rm -R /home/$NAME/.rtorrent.rc
	rm -R /var/www/html/rutorrent
	rm /etc/systemd/system/rtorrent.service
}
#########################################################

#Main
#########################################################
CHECK_ROOT
if [ $SETUP == install ]
then
	GREETINGS
	GET_USERNAME
	GET_WEBSERVER
	DEPENDENCIES
	DOWNLOAD_STUFF
	LIBTORRENT_COMPILE
	RTORRENT_COMPILE
	SYSTEMD_SERVICE
	RUTORRENT
	WEBSERVER_CONFIGURE
	RTORRENT_CONFIGURE
	COMPLETE
elif [ $SETUP == uninstall ]
then
	UNINSTALL
fi
#########################################################
