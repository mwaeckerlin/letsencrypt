# Provides a docker volume with letsencrypt certificates
# e.g. to be used by mwaeckerlin/reverse-proxy
FROM ubuntu:latest
MAINTAINER mwaeckerlin
ENV TERM "xterm"

VOLUME /etc/ssl/private

# for DOMAINS you can simply add letsencrypt parameters, such as:
# 
ENV DOMAINS ""
ENV HTTP_PORT "80"
ENV HTTPS_PORT "443"

EXPOSE 80
EXPOSE 443

ADD start.sh /start.sh
ADD renew.sh /renew.sh

WORKDIR /opt
RUN apt-get update
RUN apt-get install -y git python3-pip
RUN git clone https://github.com/letsencrypt/letsencrypt
WORKDIR /tmp
RUN /opt/letsencrypt/letsencrypt-auto -t -vvv --debug --help

CMD /start.sh
