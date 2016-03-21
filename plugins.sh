#!/bin/bash

#Variables
#######################################
CHOICE=

#######################################
function CHECK_ROOT
{
	if [ $(id -u) != 0 ]
	then
	echo "This script must be run as root"
	exit 1
	fi
}

function LIST_AVAILABLE
{
	echo "Available plugins:"
	
	if [ -d /var/www/html/rutorrent/plugins/_getdir ]
	then
	echo "1) _getdir (installed)"
	else
	echo "1) _getdir"
	fi
	
	if [ -d /var/www/html/rutorrent/plugins/_noty ]
	then
	echo "2) _noty (installed)"
	else
	echo "2) _noty"
	fi
	
	echo "3) _task"
	echo "4) autotools"
	echo "5) check_port"
	echo "6) chunks"
	echo "7) cookies"
	echo "8) cpuload"
	echo "9) create"
	echo "10) data"
	echo "11) datadir"
	echo "12) diskspace"
	echo "13) edit"
	echo "14) erasedata"
	echo "15) extratio"
	echo "16) extsearch"
	echo "17) feeds"
	echo "18) filedrop"
	echo "19) geoip"
	echo "20) history"
	echo "21) httprpc"
	echo "22) ipad"
	echo "23) loginmgr"
	echo "24) lookat"
	echo "25) mediainfo"
	echo "26) ratio"
	echo "27) retrackers"
	echo "28) rpc"
	echo "29) rss"
	echo "30) rssurlrewrite"
	echo "31) rutracker_check"
	echo "32) scheduler"
	echo "33) screenshots"
	echo "34) seedingtime"
	echo "35) show_peers_like_wtorrent"
	echo "36) source"
	echo "37) theme"
	echo "38) throttle"
	echo "39) tracklabels"
	echo "40) trafic"
	echo "41) unpack"
}

function GET_CHOOSE
{
	read -a CHOICE
	
	cd /var/www/html/rutorrent/plugins
	
	for i in "${CHOICE[@]}"
	do
		case $i in
		"1") wget -c https://bintray.com/artifact/download/novik65/generic/plugins/_getdir-3.6.tar.gz
		     tar -xf _getdir-3.6.tar.gz
		     rm _getdir-3.6.tar.gz;;
		"2") wget -c https://bintray.com/artifact/download/novik65/generic/plugins/_noty-3.6.tar.gz
		     tar -xf _noty-3.6.tar.gz
		     rm _noty-3.6.tar.gz;;
		"3") 
		"q") exit 0;;
		*) echo "Number out of range";;
	esac
	done

}

CHECK_ROOT
LIST_AVAILABLE
GET_CHOOSE
