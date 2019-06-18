FROM mwaeckerlin/base
MAINTAINER mwaeckerlin
ARG wwwuser="nginx"

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV MAILCONTACT ""
ENV LETSENCRYPT "on"

ENV WWWUSER "${wwwuser}"
ENV CONTAINERNAME "letsencrypt"
ADD renew.letsencrypt.sh /etc/periodic/monthly/renew
ADD letsencrypt-config.sh /letsencrypt-config.sh
ADD letsencrypt-dns-authenticator.sh /letsencrypt-dns-authenticator.sh
ADD letsencrypt-dns-cleanup.sh /letsencrypt-dns-cleanup.sh

WORKDIR /tmp
ENV userdirs "/acme/.well-known /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt"
RUN adduser -SDHG $SHARED_GROUP_NAME $WWWUSER \
 && apk add --no-cache --purge --clean-protected -u certbot dcron libcap \
 && mkdir -p ${userdirs} \
 && chown -R ${WWWUSER}:${SHARED_GROUP_NAME} ${userdirs} /usr/sbin/crond \
 && chmod -R g=rX /etc/letsencrypt \
 && setcap cap_net_bind_service=+ep $(which certbot)

VOLUME /etc/letsencrypt
EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

# pass inherited build arguments to children
ONBUILD RUN mv /start.sh /letsencrypt.start.sh
ONBUILD ADD start.sh /start.sh
ONBUILD ADD health.sh /health.sh
ONBUILD ARG lang
ONBUILD ENV LANG=${lang:-${LANG}}

