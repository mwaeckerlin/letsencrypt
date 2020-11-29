FROM mwaeckerlin/very-base as build
RUN $PKG_INSTALL certbot
RUN mkdir /acme /etc/letsencrypt
RUN $ALLOW_USER /acme /etc/letsencrypt
RUN tar cp \
    /acme /etc/letsencrypt /usr/lib/python* \
    $(which python3) \
    $(which certbot) \
    $(for f in $(which python3) $(find /usr/lib/python* -name '*.so*'); do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/
RUN tar cp \
    $(find /root -type l ! -exec test -e {} \; -exec echo -n "{} " \; -exec readlink {} \; | sed 's,/root\(.*\)/[^/]* \(.*\),\1/\2,') 2> /dev/null \
    | tar xpC /root/

FROM mwaeckerlin/cron as certbot
ENV CONTAINERNAME "letsencrypt"
VOLUME /etc/letsencrypt/live
COPY --from=build /root /
ADD renew.letsencrypt.sh /etc/periodic/daily/renew
ADD letsencrypt-config.sh /letsencrypt-config.sh
ADD letsencrypt-dns-authenticator.sh /letsencrypt-dns-authenticator.sh
ADD letsencrypt-dns-cleanup.sh /letsencrypt-dns-cleanup.sh
