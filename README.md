#rTorrent + libTorrent + ruTorrent + Apache + XMLRPC-C installation script for Debian >= 8 / Ubuntu >= 15.04 and Alpine Linux
[![Build Status](https://travis-ci.org/dawidd6/seedbox.svg?branch=master)](https://travis-ci.org/dawidd6/seedbox)
###What this script is doing (Debian / Ubuntu)
- **rTorrent**: downloads source, builds, installs, makes systemd's service, there's a prompt for changing default directories
- **libTorrent**: downloads source, builds, installs
- **ruTorrent**: downloads source and configures RPC, there's a prompt for interface authentication
- **Apache**: installs from repo via apt and configures for ruTorrent
- **XMLRPC-C**: downloads source, builds, installs

**script is cleaning after yourself**

###Usage
```sh
git clone https://github.com/dawidd6/seedbox.git ~/seedbox
cd ~/seedbox
sudo ./``place_here_name_of_script``.sh
```

###Packages installed via apt (Debian / Ubuntu)
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

###Packages installed via apk (Alpine Linux)
```sh
rtorrent
libtorrent
xmlrpc-c
openssl
git
apache2
apache2-utils
gcc
g++	
automake
libtool
cppunit-dev
ncurses-dev
ncurses
ncurses-libs
libssl1.0
php
php-cgi
php-curl
php-cli
php-apache2
screen
wget
make
libsigc++-dev
```
***Script was tested on Debian 8 Jessie / Ubuntu 15.10 and Alpine Linux***

