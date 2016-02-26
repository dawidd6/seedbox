#rTorrent + libTorrent + ruTorrent + Apache + XMLRPC-C installation script for Debian and derivatives with systemd
[![Build Status](https://travis-ci.org/dawidd6/seedbox.svg?branch=master)](https://travis-ci.org/dawidd6/seedbox)
###What this script is doing
- **rTorrent**: downloads source, builds, installs, makes systemd's service, there's a prompt for changing default directories
- **libTorrent**: downloads source, builds, installs
- **ruTorrent**: downloads source and configures RPC, there's a prompt for interface authentication
- **Apache**: installs from repo via apt and configures for ruTorrent
- **XMLRPC-C**: downloads source, builds, installs

**script is cleaning after yourself**

###Usage
```sh
git clone https://github.com/dawidd6/seedbox.git
cd seedbox
sudo ./rtorrent-rutorrent-xmlrpcc-apache.sh
```

###Dependencies
```sh
openssl
git
apache2
apache2-utils
build-essential
libsigc++-2.0-dev
libcurl4-openssl-dev 
automake 
libtool 
libcppunit-dev 
libncurses5-dev 
libapache2-mod-scgi
php5 
php5-cgi 
php5-curl 
php5-cli 
libapache2-mod-php5 
screen 
unzip 
libssl-dev 
wget 
curl
```
***Script was tested on Debian 8 Jessie and Ubuntu 15.10***

