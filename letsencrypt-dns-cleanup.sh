#!/bin/bash -e

test -e /etc/bind/${CERTBOT_DOMAIN}
sed -e "/${CERTBOT_VALIDATION}/d" \
    -e "s/[0-9]\+\t; Serial/${SERIAL:-$(date +%s)}	; Serial/" \
    -i /etc/bind/${CERTBOT_DOMAIN}
kill -HUP $(pgrep named)
