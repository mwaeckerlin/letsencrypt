#!/bin/bash -e

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
        return 0
    fi
    local server=$1
    local subs="$(echo ${2:-www} | tr ' ' '\n' | sed '/\*/d' | tr '\n' ' ')"
    local mail="--register-unsafely-without-email"
    echo "    - server ${server} get certificates from let's encrypt"
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
                       -d ${subs// /.${server} -d } ${server} ${mail}; then
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
                       -d ${server} -d www.${server} ${mail}; then
                echo "#### Lets' Encrypt success"
            else
                echo "**** Lets' Encrypt fail"
            fi
        else
            # fallback standalone, needs access to ports 80, 443
            if certbot certonly -n --agree-tos -a standalone \
                       -d ${server} -d www.${server} ${mail}; then
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
    cp /renew.letsencrypt.sh /etc/cron.monthly/renew
}
