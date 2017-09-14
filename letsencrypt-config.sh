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
    local subs="${2:-www} "
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
            certbot certonly -n --agree-tos -a webroot --webroot-path=/acme \
                    -d ${subs// /.${server} -d } ${server} ${mail}
        elif test -e /etc/bind/$server && pgrep named 2>&1 > /dev/null; then
            # use dns to get certificates
            certbot certonly -n --agree-tos --manual-public-ip-logging-ok \
                    --preferred-challenges dns --manual \
                    --manual-auth-hook /letsencrypt-dns-authenticator.sh \
                    --manual-cleanup-hook /letsencrypt-dns-cleanup.sh \
                    -d ${server} -d www.${server} ${mail}
        else
            # fallback standalone, needs access to ports 80, 443
            certbot certonly -n --agree-tos -a standalone \
                    -d ${server} -d www.${server} ${mail}
        fi
    fi
    if ! test -e "$(certfile $server)" -a -e "$(keyfile $server)"; then
        echo "**** ERROR: Installation of Let's Encrypt certificates failed for $server" 1>&2
        exit 1
    fi
    cp /renew.letsencrypt.sh /etc/cron.monthly/renew
}