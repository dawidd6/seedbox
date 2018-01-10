#BUILD IMAGE
#docker build -t seedbox-image .

#CONTAINER RUN
#docker run -dt -p 80:80 -p 44444:44444 --name seedbox-container seedbox-image

#CONTAINER CREATE AND START
#docker create -t -p 80:80 -p 44444:44444 --name seedbox-container seedbox-image
#docker start seedbox-container

FROM alpine:edge

MAINTAINER dawidd6

ENV RUTORRENT_USER user
ENV RUTORRENT_PASS pass

ADD http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz /tmp

RUN apk update && \
	apk add screen rtorrent xmlrpc-c lighttpd lighttpd-mod_auth php7-cgi openssl && \
	tar -xz -C /var/www/localhost/htdocs -f /tmp/rutorrent-3.6.tar.gz && \
	rm /tmp/rutorrent-3.6.tar.gz && \
	printf "include \"seedbox.conf\"\n" >> /etc/lighttpd/lighttpd.conf && \
	printf "${RUTORRENT_USER}:$(openssl passwd -crypt ${RUTORRENT_PASS})\n" >> /var/www/localhost/htdocs/rutorrent/.htpasswd && \
	mkdir -p /run/lighttpd && \
	chown -R lighttpd:lighttpd /run/lighttpd

COPY files/start.sh /
COPY files/.rtorrent.rc /root
COPY files/seedbox.conf /etc/lighttpd

CMD ["/start.sh"]
