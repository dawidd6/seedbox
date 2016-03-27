#Variables
#########################################################
NAME=$(printf '%s\n' "${SUDO_USER:-$USER}")
BOOL=true
CHOICE=

RTORRENT_DOWNLOAD_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^directory/ {print $3;}')"
RTORRENT_SESSION_DIR="$(cat /home/$NAME/.rtorrent.rc |awk '/^session/ {print $3;}')"

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

SETUP=$1
#########################################################

#Greetings
#########################################################
GREETINGS()
{
	 echo -e "\n\e[1;36mVersions of components to be installed:\e[0m"
	 echo "-----------------------------------------------------"
	 echo -e "\e[1;32mxmlrpc-c\e[0m - \e[1;31mstable\e[0m"
	 echo -e "\e[1;32mlibtorrent\e[0m - \e[1;31m0.13.6\e[0m"
	 echo -e "\e[1;32mrtorrent\e[0m - \e[1;31m0.9.6\e[0m"
	 echo -e "\e[1;32mrutorrent\e[0m - \e[1;31m3.6\e[0m"
	 echo "-----------------------------------------------------"
	 echo -e "\nScript has been assembled by \e[1mdawidd6\e[0m\n"
}
#########################################################

#Various Shit
#########################################################
CHECK_ROOT()
{
	if [ $(id -u) != 0 ]
	then
	echo "This script must be run as root"
	exit 1
	fi
}

GET_USERNAME()
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

GET_WEBSERVER()
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

#Rtorrent Configuration
#########################################################
RTORRENT_CONFIGURE()
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

#Complete
#########################################################
COMPLETE()
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
	echo "Please reboot your system to ensure all is working proper!"
}
#########################################################
