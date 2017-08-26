#!/bin/sh

if [ -e /root/rtorrent.lock ]; then
	echo "Removing rtorrent.lock ..."
	rm -rf /root/rtorrent.lock
fi

echo "Starting rtorrent ..."
screen -dmS rtorrent rtorrent
echo "Starting lighttpd ..."
lighttpd -D -f /etc/lighttpd/lighttpd.conf
