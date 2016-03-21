#rTorrent + libTorrent + ruTorrent + Webserver + XMLRPC-C installation script
[![Build Status](https://travis-ci.org/dawidd6/seedbox.svg?branch=master)](https://travis-ci.org/dawidd6/seedbox)

###Usage
```sh
git clone https://github.com/dawidd6/seedbox.git ~/seedbox
cd ~/seedbox
sudo ./"scriptname".sh
```
###Supported distributions
- Debian-based distro with systemd onboard
- Alpine Linux

###Features
- Currently there is choose between Apache and Lighttpd
- Script is cleaning after yourself
- Script asks for custom directories for rtorrent (or leaves default)
