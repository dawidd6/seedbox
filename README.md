#rTorrent + ruTorrent + Apache + XMLRPC-C installation script for Ubuntu >= 15.04
[![Build Status](https://travis-ci.org/dawidd6/seedbox.svg?branch=master)](https://travis-ci.org/dawidd6/seedbox)
###What this script is doing
1. Downloads source of xmlrpc-c super stable, builds it and installs
2. Downloads source of libtorrent + rtorrent, builds it and installs
3. Downloads needed dependencies via apt-get
4. Makes rtorrent systemd's service, starts it and enables
5. Downloads rutorrent and configures apache to work with it

###Usage
```sh
git clone https://github.com/dawidd6/seedbox.git
cd seedbox
sudo ./rtorrent-rutorrent-xmlrpcc-apache.sh
```

###Packages which script installs
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
