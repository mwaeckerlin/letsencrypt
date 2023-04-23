FROM mwaeckerlin/very-base as build
RUN $PKG_INSTALL certbot
RUN mkdir /acme /etc/letsencrypt /var/log/letsencrypt
RUN $ALLOW_USER /acme /etc/letsencrypt /var/log/letsencrypt
ADD renew.letsencrypt.sh /etc/periodic/daily/renew
ADD letsencrypt-start.sh /letsencrypt-start.sh

FROM mwaeckerlin/cron as cron

FROM mwaeckerlin/cron as letsencrypt
ENV CONTAINERNAME "letsencrypt"
ENV MODE "webroot"
ENV PREPEND "www"
COPY --from=build / /
COPY --from=cron / /
CMD [ "/letsencrypt-start.sh" ]