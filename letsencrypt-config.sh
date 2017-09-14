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
    local server=$1
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
            certbot certonly -n --agree-tos -a webroot --webroot-path=/acme -d ${server} -d www.${server} ${mail}
        else
            certbot certonly -n --agree-tos -a standalone -d ${server} -d www.${server} ${mail}
        fi
    fi
    if ! test -e "$(certfile $server)" -a -e "$(keyfile $server)"; then
        echo "**** ERROR: Installation of Let's Encrypt certificates failed for $server" 1>&2
        exit 1
    fi
    cp /renew.letsencrypt.sh /etc/cron.monthly/renew
}
