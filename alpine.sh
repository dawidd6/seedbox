#!/bin/bash

source include.sh

#Dependencies
#########################################################
function DEPENDENCIES
{
	apk update
	
	if [ $WEBSERVER = 1 ]
	then
	apk add apache2 apache2-utils php-apache2
	elif [ $WEBSERVER = 2 ]
	then
	apk add lighttpd lighttpd-mod_auth
	fi
	
	apk add rtorrent libtorrent xmlrpc-c openssl \
	libtool cppunit-dev ncurses-dev ncurses ncurses-libs libssl1.0 \
	php php-cgi php-curl php-cli screen wget libsigc++-dev
}
#########################################################

#Download
#########################################################
function DOWNLOAD_STUFF
{
	cd /tmp
	wget -c http://dl.bintray.com/novik65/generic/$RUTORRENT_TARBALL
}
#########################################################

#Service
#########################################################
function OPENRC_SERVICE
{
	cat > "/etc/init.d/rtorrentd" <<-EOF
	#!/sbin/runscript

	depend()
	{
		use net ypbind nis
	}

	start()
	{
		ebegin "Starting rtorrent"
		start-stop-daemon \
		--start \
		--make-pidfile \
		--pidfile /var/run/rtorrentd.pid \
		--background \
		--user $NAME \
		--name rtorrentd \
		--exec /usr/bin/screen -- -D -m -S rtorrentd /usr/bin/rtorrent
		eend $?
	}

	stop()
	{
		ebegin "Stopping rtorrent"
		start-stop-daemon --stop --signal 15 \
		--pidfile /var/run/rtorrentd.pid
		eend $?
	}
	EOF
	
	chmod +x /etc/init.d/rtorrentd
	/etc/init.d/rtorrentd start
	rc-update add rtorrentd default
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
	
	mv /tmp/$RUTORRENT_TARBALL /var/www/localhost/htdocs
	cd /var/www/localhost/htdocs
	tar -zxf $RUTORRENT_TARBALL
	rm $RUTORRENT_TARBALL
}
#########################################################

#Webservers
#########################################################
function WEBSERVER_CONFIGURE
{
	if [ $WEBSERVER = 1 ]
	then
		htpasswd -cb /var/www/localhost/htdocs/rutorrent/.htpasswd $RUTORRENT_USER $RUTORRENT_PASS
		if uname -m|grep -wq x86_64
		then
		cp /home/$NAME/seedbox/files/x86_64/mod_scgi.so /var/www/modules
		elif uname -m|grep -wq x86
		then
		cp /home/$NAME/seedbox/files/x86/mod_scgi.so /var/www/modules
		elif uname -m|grep -q arm
		then
		cp /home/$NAME/seedbox/files/armhf/mod_scgi.so /var/www/modules
		fi
	
		cat >> "/etc/apache2/httpd.conf" <<-EOF
	    	LoadModule scgi_module modules/mod_scgi.so
	    	
	    	SCGIMount /RPC2 127.0.0.1:5000

	    	<Directory "/var/www/localhost/htdocs/rutorrent">
		AuthName "ruTorrent interface"
		AuthType Basic
		Require valid-user
		AuthUserFile /var/www/localhost/htdocs/rutorrent/.htpasswd
	    	</Directory>
		EOF
	
		/etc/init.d/apache2 start
		rc-update add apache2 default
		
	elif [ $WEBSERVER = 2 ]
	then
		printf "$RUTORRENT_USER:$(openssl passwd -crypt $RUTORRENT_PASS)\n" >> /var/www/localhost/htdocs/rutorrent/.htpasswd
	
		sed -i -e 's@#    "mod_auth",@     "mod_auth",@g' /etc/lighttpd/lighttpd.conf
		sed -i -e 's@#    "mod_ssi",@     "mod_scgi",@g' /etc/lighttpd/lighttpd.conf
		sed -i -e 's@#   include "mod_fastcgi.conf"@include "mod_fastcgi.conf"@g' /etc/lighttpd/lighttpd.conf
		sed -i -e "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=1@g" /etc/php/php.ini
		cat >> "/etc/lighttpd/lighttpd.conf" <<-EOF
		auth.backend = "htpasswd"
		auth.backend.htpasswd.userfile = "/var/www/localhost/htdocs/rutorrent/.htpasswd"
		auth.require = ( "/rutorrent" =>
	    	(
	    	"method"  => "basic",
	    	"realm"   => "ruTorrent interface",
	    	"require" => "valid-user"
	    	),
		)
		EOF
	
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
	
		/etc/init.d/lighttpd restart
		rc-update add lighttpd default
	fi
}

#Uninstall
#########################################################
UNINSTALL()
{
	apk del rtorrent libtorrent xmlrpc-c openssl cppunit-dev ncurses-dev ncurses \
	ncurses-libs libssl1.0 php php-cgi php-curl php-cli screen libsigc++-dev

	if apk info |grep -q apache
	then
	apk del apache2 apache2-utils php-apache2
	elif apk info |grep -q lighttpd
	then
	apk del lighttpd lighttpd-mod_auth
	fi
	
	RTORRENT_DOWNLOAD_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^directory/ {print $3;}')"
	RTORRENT_SESSION_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^session/ {print $3;}')"

	rm -R "$RTORRENT_DOWNLOAD_DIR"
	rm -R "$RTORRENT_SESSION_DIR"
	rm -R /home/$NAME/.rtorrent.rc
	rm -R /var/www/localhost/htdocs/rutorrent
	rm /etc/init.d/rtorrentd
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
	OPENRC_SERVICE
	RUTORRENT
	WEBSERVER_CONFIGURE
	RTORRENT_CONFIGURE
	COMPLETE
elif [ $SETUP == uninstall ]
then
	UNINSTALL
fi
#########################################################
