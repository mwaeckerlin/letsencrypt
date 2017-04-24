# Provides a docker volume with letsencrypt certificates
# e.g. to be used by mwaeckerlin/reverse-proxy
FROM mwaeckerlin/ubuntu-base
MAINTAINER mwaeckerlin

ENV HTTP_PORT "80"
ENV HTTPS_PORT "443"

EXPOSE 80
EXPOSE 443

ADD start.letsencrypt.sh /start.letsencrypt.sh
ADD renew.letsencrypt.sh /renew.letsencrypt.sh
ADD config.nginx.sh /config.nginx.sh

WORKDIR /tmp
RUN apt-get update
RUN apt-get install -y letsencrypt
RUN mkdir -p /acme/.well-known

ENTRYPOINT /start.letsencrypt.sh

VOLUME /etc/letsencrypt
