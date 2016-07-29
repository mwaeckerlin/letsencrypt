# Provides a docker volume with letsencrypt certificates
# e.g. to be used by mwaeckerlin/reverse-proxy
FROM ubuntu
MAINTAINER mwaeckerlin
ENV TERM "xterm"

VOLUME /etc/ssl/private

# for DOMAINS you can simply add letsencrypt parameters, such as e.g.:
#   -m mail@domain1.tld -d domain1.tld -m mail@domain2.tld -d domain2.tld
ENV DOMAINS ""
ENV LETSENCRYPT_OPTIONS ""
ENV HTTP_PORT "80"
ENV HTTPS_PORT "443"

EXPOSE 80
EXPOSE 443

ADD start.sh /start.sh
ADD renew.sh /renew.sh

WORKDIR /tmp
RUN apt-get update
RUN apt-get install -y letsencrypt

CMD /start.sh
