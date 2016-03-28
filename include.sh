#Variables
#########################################################
NAME="$(printf '%s\n' "${SUDO_USER:-$USER}")"
BOOL=true
CHOICE=

RTORRENT_DOWNLOAD_DIR=
RTORRENT_SESSION_DIR=

LIBTORRENT_TARBALL=libtorrent-0.13.6.tar.gz
LIBTORRENT_DIR=libtorrent-0.13.6

RTORRENT_TARBALL=rtorrent-0.9.6.tar.gz
RTORRENT_DIR=rtorrent-0.9.6

RUTORRENT_TARBALL=rutorrent-3.6.tar.gz

RUTORRENT_USER=
RUTORRENT_PASS=

WEBSERVER=0

SETUP="$1"
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
	cat > "/home/$NAME/.rtorrent.rc" <<-EOF
	# This is an example resource file for rTorrent. Copy to
	# ~/.rtorrent.rc and enable/modify the options as needed. Remember to
	# uncomment the options you wish to enable.

	# Maximum and minimum number of peers to connect to per torrent.
	#min_peers = 40
	#max_peers = 100

	# Same as above but for seeding completed torrents (-1 = same as downloading)
	#min_peers_seed = 10
	#max_peers_seed = 50

	# Maximum number of simultanious uploads per torrent.
	#max_uploads = 15

	# Global upload and download rate in KiB. "0" for unlimited.
	#download_rate = 0
	#upload_rate = 0

	# Default directory to save the downloaded torrents.
	directory = /home/$NAME/rtorrent/downloads

	# Default session directory. Make sure you don't run multiple instance
	# of rtorrent using the same session directory. Perhaps using a
	# relative path?
	session = /home/$NAME/rtorrent/.rtorrent-session

	# Watch a directory for new torrents, and stop those that have been
	# deleted.
	#schedule = watch_directory,5,5,load_start=./watch/*.torrent
	#schedule = untied_directory,5,5,stop_untied=

	# Close torrents when diskspace is low.
	schedule = low_diskspace,5,60,close_low_diskspace=100M

	# The ip address reported to the tracker.
	#ip = 127.0.0.1
	#ip = rakshasa.no

	# The ip address the listening socket and outgoing connections is
	# bound to.
	#bind = 127.0.0.1
	#bind = rakshasa.no

	# Port range to use for listening.
	port_range = 6790-6999

	# Start opening ports at a random position within the port range.
	#port_random = no

	# Check hash for finished torrents. Might be usefull until the bug is
	# fixed that causes lack of diskspace not to be properly reported.
	#check_hash = no

	# Set whetever the client should try to connect to UDP trackers.
	#use_udp_trackers = yes

	# Alternative calls to bind and ip that should handle dynamic ip's.
	#schedule = ip_tick,0,1800,ip=rakshasa
	#schedule = bind_tick,0,1800,bind=rakshasa

	# Encryption options, set to none (default) or any combination of the following:
	# allow_incoming, try_outgoing, require, require_RC4, enable_retry, prefer_plaintext
	#
	# The example value allows incoming encrypted connections, starts unencrypted
	# outgoing connections but retries with encryption if they fail, preferring
	# plaintext to RC4 encryption after the encrypted handshake
	#
	encryption = allow_incoming,enable_retry,try_outgoing

	# Enable DHT support for trackerless torrents or when all trackers are down.
	# May be set to "disable" (completely disable DHT), "off" (do not start DHT),
	# "auto" (start and stop DHT as needed), or "on" (start DHT immediately).
	# The default is "off". For DHT to work, a session directory must be defined.
	# 
	# dht = auto

	# UDP port to use for DHT. 
	# 
	# dht_port = 6881

	# Enable peer exchange (for torrents not marked private)
	#
	# peer_exchange = yes

	#
	# Do not modify the following parameters unless you know what you're doing.
	#

	# Hash read-ahead controls how many MB to request the kernel to read
	# ahead. If the value is too low the disk may not be fully utilized,
	# while if too high the kernel might not be able to keep the read
	# pages in memory thus end up trashing.
	#hash_read_ahead = 10

	# Interval between attempts to check the hash, in milliseconds.
	#hash_interval = 100

	# Number of attempts to check the hash while using the mincore status,
	# before forcing. Overworked systems might need lower values to get a
	# decent hash checking rate.
	#hash_max_tries = 10

	scgi_port = 127.0.0.1:5000
	EOF

	echo -e "\nDefault directory for downloads is: /home/$NAME/rtorrent/downloads"
	echo -e "Default directory for session files is: /home/$NAME/rtorrent/.rtorrent-session\n"
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
