#rTorrent + libTorrent + ruTorrent + Webserver + XMLRPC-C (un)installation script
[![Build Status](https://travis-ci.org/dawidd6/seedbox.svg?branch=master)](https://travis-ci.org/dawidd6/seedbox)

###Script is under development
###Contributions are welcome

###Usage
One can use make to easily open right script:
```sh
git clone https://github.com/dawidd6/seedbox.git ~/seedbox
cd ~/seedbox
make
```
When you type `make` you will get possible commands

Or one can open desired script manually:
```sh
git clone https://github.com/dawidd6/seedbox.git ~/seedbox
cd ~/seedbox
sudo ./"script" install
#or
sudo ./"script" uninstall
```
###Supported distributions
- Debian >= 8
- Ubuntu >= 15.04
- Alpine Linux
- Arch Linux

###Features
- Currently there is choose between Apache and Lighttpd
- Script is cleaning after yourself
- Script asks for custom directories for rtorrent (or leaves default)
- Install or uninstall


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/dawidd6/seedbox/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

