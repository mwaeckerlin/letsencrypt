#!/bin/bash -e

if ! test -e /etc/bind/${CERTBOT_DOMAIN}; then
    echo "**** ERROR: file not found /etc/bind/${CERTBOT_DOMAIN}" 1>&2
    exit 1
fi
sed -e '/^_acme-challenge/d' \
    -e "s/[0-9]\+\t; Serial/${SERIAL:-$(date +%s)}	; Serial/" \
    -e '/^@[ \t]\+IN[ \t]\+A/a_acme-challenge	300	IN	TXT "'"${CERTBOT_VALIDATION}"'"' \
    -i /etc/bind/${CERTBOT_DOMAIN}
kill -HUP $(pgrep named)
