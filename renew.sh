#! /bin/bash -ex

/opt/letsencrypt/letsencrypt-auto certonly \
    -vvv --debug  -t --register-unsafely-without-email \
    --duplicate --renew-by-default --agree-tos \
    --rsa-key-size 4096 --cert-path /etc/ssl/private --key-path /etc/ssl/private \
    --standalone \
    $*
