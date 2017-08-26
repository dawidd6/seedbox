#BUILD IMAGE
#docker build -t seedbox-image .

#CONTAINER RUN
#docker run -dt -p 80:80 -p 44444:44444 --name seedbox-container seedbox-image

#CONTAINER CREATE AND START
#docker create -t -p 80:80 -p 44444:44444 --name seedbox-container seedbox-image
#docker start seedbox-container

FROM alpine:edge

MAINTAINER dawidd6

ADD http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz /tmp

RUN apk update && \
	apk add screen rtorrent xmlrpc-c lighttpd lighttpd-mod_auth php5-cgi php5 php5-cli openssl && \
	tar -xz -C /var/www/localhost/htdocs -f /tmp/rutorrent-3.6.tar.gz && \
	rm /tmp/rutorrent-3.6.tar.gz && \
	printf "include \"mod_fastcgi.conf\"\n" >> /etc/lighttpd/lighttpd.conf && \
	printf "include \"seedbox.conf\"\n" >> /etc/lighttpd/lighttpd.conf && \
	printf "user:$(openssl passwd -crypt pass)\n" >> /var/www/localhost/htdocs/rutorrent/.htpasswd && \
	printf "cgi.fix_pathinfo=1\n" >> /etc/php5/php.ini && \
	ln -s /usr/bin/php-cgi5 /usr/bin/php-cgi && \
	mkdir -p /run/lighttpd && \
	chown -R lighttpd:lighttpd /run/lighttpd

COPY files/start.sh /usr/bin
COPY files/.rtorrent.rc /root
COPY files/seedbox.conf /etc/lighttpd

CMD ["/usr/bin/start.sh"]
