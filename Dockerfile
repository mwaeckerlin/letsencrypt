# Provides a docker volume with letsencrypt certificates
# e.g. to be used by mwaeckerlin/reverse-proxy
FROM mwaeckerlin/ubuntu-base
MAINTAINER mwaeckerlin

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV MAILCONTACT ""
ENV LETSENCRYPT "on"

ADD start.letsencrypt.sh /start.letsencrypt.sh
ADD renew.letsencrypt.sh /renew.letsencrypt.sh
ADD config.nginx.sh /config.nginx.sh
ADD letsencrypt-config.sh /letsencrypt-config.sh
ADD letsencrypt-dns-authenticator.sh /letsencrypt-dns-authenticator.sh
ADD letsencrypt-dns-cleanup.sh /letsencrypt-dns-cleanup.sh

WORKDIR /tmp
RUN add-apt-repository -y ppa:certbot/certbot
RUN apt-get update
RUN apt-get install -y certbot
RUN mkdir -p /acme/.well-known

ENTRYPOINT /start.letsencrypt.sh

VOLUME /etc/letsencrypt
