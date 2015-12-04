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

WORKDIR /opt
RUN apt-get update
RUN apt-get install -y git python3-pip python3-urllib3
RUN git clone https://github.com/letsencrypt/letsencrypt
WORKDIR /tmp
RUN /opt/letsencrypt/letsencrypt-auto -t -vvv --debug --help

CMD /start.sh
