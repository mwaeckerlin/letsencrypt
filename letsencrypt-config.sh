#!/bin/sh -e

chgrp -R $SHARED_GROUP_NAME /etc/letsencrypt
chmod -R g=rX /etc/letsencrypt

certfile() {
    local server=$1
    echo "/etc/letsencrypt/live/${server}/fullchain.pem"
}

keyfile() {
    local server=$1
    echo "/etc/letsencrypt/live/${server}/privkey.pem"
}

havecerts() {
    local server=$1
    test -e "$(certfile $server)" -a -e "$(keyfile $server)"
}

installcerts() {
    if test "$LETSENCRYPT" = "off"; then
	rm /etc/periodic/monthly/renew
        return 0
    fi
    local server=$1
    local subs="${2:-www}"
    local mail="--register-unsafely-without-email"
    local domainlist="-d ${server}"
    echo "    - server ${server} get certificates from let's encrypt"
    for d in $subs; do
        domainlist+=" -d ${d}.${server}"
    done
    if test -n "${MAILCONTACT}"; then
        if [[ "${MAILCONTACT}" =~ @ ]]; then
            mail="-m ${MAILCONTACT}"
        else
            mail="-m ${MAILCONTACT}@${server}"
        fi
    fi
    if ! test -e "$(certfile $server)" -a -e "$(keyfile $server)"; then
        if pgrep nginx 2>&1 > /dev/null; then
            # use running nginx to get certificates
            if certbot certonly -n --agree-tos -a webroot --webroot-path=/acme \
                       ${domainlist} ${mail}; then
                echo "#### Lets' Encrypt success"
            else
                echo "**** Lets' Encrypt fail"
            fi
        elif test -e /etc/bind/$server && pgrep named 2>&1 > /dev/null; then
            # use dns to get certificates
            if certbot certonly -n --agree-tos --manual-public-ip-logging-ok \
                       --preferred-challenges dns --manual \
                       --manual-auth-hook /letsencrypt-dns-authenticator.sh \
                       --manual-cleanup-hook /letsencrypt-dns-cleanup.sh \
                       ${domainlist} ${mail}; then
                echo "#### Lets' Encrypt success"
            else
                echo "**** Lets' Encrypt fail"
            fi
        else
            # fallback standalone, needs access to ports 80, 443
            if certbot certonly -n --agree-tos -a standalone \
                       ${domainlist} ${mail}; then
                echo "#### Lets' Encrypt success"
            else
                echo "**** Lets' Encrypt fail"
            fi
        fi
    fi
    if ! test -e "$(certfile $server)" -a -e "$(keyfile $server)"; then
        echo "**** ERROR: Installation of Let's Encrypt certificates failed for $server" 1>&2
        return 0
    fi
}
