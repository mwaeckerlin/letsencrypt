#! /bin/sh -ex
certbot renew ${OPTIONS} -n --agree-tos --${MODE:-webroot} --work-dir /tmp -w /.well-known ${EMAIL:+-m} ${EMAIL}
