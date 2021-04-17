#! /bin/sh -ex
certbot renew ${OPTIONS} -n --agree-tos --${MODE:-webroot} --work-dir /tmp -w /acme ${EMAIL:+-m} ${EMAIL}
