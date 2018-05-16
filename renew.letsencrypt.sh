#! /bin/sh -ex

certbot renew -n -a webroot --webroot-path=/acme
if nginx -t; then
    nginx -s reload
fi
