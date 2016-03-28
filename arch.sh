#!/bin/bash

source include.sh

#Dependencies
#########################################################
DEPENDENCIES()
{	
	if [ $WEBSERVER = 1 ]
	then
	pacman -Sy --noconfirm apache php-apache
	elif [ $WEBSERVER = 2 ]
	then
	pacman -Sy --noconfirm lighttpd
	fi
	
	pacman -S --noconfirm rtorrent libtorrent xmlrpc-c openssl libtool cppunit ncurses php php-cgi screen wget libsigc++
}
#########################################################

#Download
#########################################################
DOWNLOAD_STUFF()
{
	cd /tmp
	wget -c http://dl.bintray.com/novik65/generic/$RUTORRENT_TARBALL
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
	
	mv /tmp/$RUTORRENT_TARBALL /srv/http
	cd /srv/http
	tar -xf $RUTORRENT_TARBALL
	rm $RUTORRENT_TARBALL
	
	echo "$NAME:x:1000:" >> /etc/group
}
#########################################################

#Webservers
#########################################################
WEBSERVER_CONFIGURE()
{
	if [ $WEBSERVER = 1 ]
	then
		htpasswd -cb /srv/http/rutorrent/.htpasswd $RUTORRENT_USER $RUTORRENT_PASS
		if uname -m|grep -wq x86_64
		then
		cp /home/$NAME/seedbox/files/x86_64/mod_scgi.so /etc/httpd/modules
		elif uname -m|grep -wq x86
		then
		cp /home/$NAME/seedbox/files/x86/mod_scgi.so /etc/httpd/modules
		elif uname -m|grep -q arm
		then
		cp /home/$NAME/seedbox/files/armhf/mod_scgi.so /etc/httpd/modules
		fi
		
		echo "Include conf/extra/php7_module.conf" >> /etc/httpd/conf/httpd.conf

		echo "LoadModule php7_module modules/libphp7.so" >> /etc/httpd/conf/httpd.conf
		
		echo "AddType application/x-httpd-php .php" >> /etc/httpd/conf/httpd.conf

		echo "AddType application/x-httpd-php-source .phps" >> /etc/httpd/conf/httpd.conf

		sed -i -e "s@LoadModule mpm_event_module modules/mod_mpm_event.so@#LoadModule mpm_event_module modules/mod_mpm_event.so@g" /etc/httpd/conf/httpd.conf
	
		sed -i -e "s@#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so@LoadModule mpm_prefork_module modules/mod_mpm_prefork.so@g" /etc/httpd/conf/httpd.conf

		cat >> "/etc/httpd/conf/httpd.conf" <<-EOF
	    	LoadModule scgi_module modules/mod_scgi.so
	    	
	    	SCGIMount /RPC2 127.0.0.1:5000

	    	<Directory "/srv/http/rutorrent">
		AuthName "ruTorrent interface"
		AuthType Basic
		Require valid-user
		AuthUserFile /srv/http/rutorrent/.htpasswd
	    	</Directory>
		EOF
	
		systemctl start httpd.service
		systemctl enable httpd.service
	
	elif [ $WEBSERVER = 2 ]
	then
		printf "$RUTORRENT_USER:$(openssl passwd -crypt $RUTORRENT_PASS)\n" >> /srv/http/rutorrent/.htpasswd
	
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
	
		sed -i -e "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=1@g" /etc/php/php.ini
	
		if ! grep --quiet "fastcgi.server" /etc/lighttpd/lighttpd.conf
		then
		cat >> "/etc/lighttpd/lighttpd.conf" <<-EOF
		fastcgi.server = ( ".php" => ((
		"bin-path" => "/usr/bin/php-cgi",
		"socket" => "/run/lighttpd/php.socket"
		)))
		EOF
		fi
	
		if ! grep --quiet "auth.backend.htpasswd.userfile" /etc/lighttpd/lighttpd.conf
		then
		cat >> "/etc/lighttpd/lighttpd.conf" <<-EOF
		auth.backend = "htpasswd"
		auth.backend.htpasswd.userfile = "/srv/http/rutorrent/.htpasswd"
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
	
		systemctl start lighttpd.service
		systemctl enable lighttpd.service
	fi
}

#Uninstall
#########################################################
UNINSTALL()
{
	pacman -Rnsc rtorrent libtorrent xmlrpc-c cppunit php php-cgi screen libsigc++

	if pacman -Qs apache > /dev/null
	then
	pacman -Rnsc apache php-apache
	elif pacman -Qs lighttpd > /dev/null
	then
	pacman -Rnsc lighttpd
	fi
	
	RTORRENT_DOWNLOAD_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^directory/ {print $3;}')"
	RTORRENT_SESSION_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^session/ {print $3;}')"

	rm -R "$RTORRENT_DOWNLOAD_DIR"
	rm -R "$RTORRENT_SESSION_DIR"
	rm -R /home/$NAME/.rtorrent.rc
	rm -R /srv/http/rutorrent
	rm /etc/systemd/system/rtorrent.service
}
#########################################################

#Main
#########################################################
CHECK_ROOT
if [ $SETUP = install ]
then
	GREETINGS
	GET_USERNAME
	GET_WEBSERVER
	DEPENDENCIES
	DOWNLOAD_STUFF
	SYSTEMD_SERVICE
	RUTORRENT
	WEBSERVER_CONFIGURE
	RTORRENT_CONFIGURE
	COMPLETE
elif [ $SETUP = uninstall ]
then
	UNINSTALL
fi
#########################################################
