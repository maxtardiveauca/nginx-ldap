FROM debian:jessie

MAINTAINER Henrik Sachse <t3x7m3@posteo.de>

ENV NGINX_VERSION release-1.11.13

# Use jessie-backports for openssl >= 1.0.2
# This is required by nginx-auth-ldap when ssl_check_cert is turned on.
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
	&& echo 'deb http://ftp.debian.org/debian/ jessie-backports main' > /etc/apt/sources.list.d/backports.list \
	&& apt-get update \
	&& apt-get install -t jessie-backports -y \
		ca-certificates \
		git \
		gcc \
		make \
		libpcre3-dev \
		zlib1g-dev \
		libldap2-dev \
		libssl-dev \
		wget

# See http://wiki.nginx.org/InstallOptions
RUN mkdir /var/log/nginx \
	&& mkdir /etc/nginx \
	&& cd ~ \
	&& git clone https://github.com/kvspb/nginx-auth-ldap.git \
	&& git clone https://github.com/nginx/nginx.git \
	&& cd ~/nginx \
	&& git checkout tags/${NGINX_VERSION} \
	&& ./auto/configure \
		--add-module=/root/nginx-auth-ldap \
		--with-http_ssl_module \
		--with-debug \
		--conf-path=/etc/nginx/nginx.conf \ 
		--sbin-path=/usr/sbin/nginx \ 
		--pid-path=/var/log/nginx/nginx.pid \ 
		--error-log-path=/var/log/nginx/error.log \ 
		--http-log-path=/var/log/nginx/access.log \
        --with-stream \
	&& make install \
	&& cd .. \
	&& rm -rf nginx-auth-ldap \
	&& rm -rf nginx \
	&& wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/v0.0.4/dockerize-linux-amd64-v0.0.4.tar.gz \
	&& tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
	&& rm -rf /tmp/dockerize.tar.gz

EXPOSE 80 443

COPY run.sh /run.sh
CMD ["/run.sh"]
