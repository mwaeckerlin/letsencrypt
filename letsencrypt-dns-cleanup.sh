#!/bin/bash -e

if ! test -e /etc/bind/${CERTBOT_DOMAIN}; then
    echo "**** ERROR: file not found /etc/bind/${CERTBOT_DOMAIN}" 1>&2
    exit 1
fi
sed -e "/${CERTBOT_VALIDATION}/d" \
    -e "s/[0-9]\+\t; Serial/${SERIAL:-$(date +%s)}	; Serial/" \
    -i /etc/bind/${CERTBOT_DOMAIN}
kill -HUP $(pgrep named)
