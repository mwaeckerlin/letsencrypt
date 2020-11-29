#! /bin/sh -ex
certbot renew -n --agree-tos -a webroot -w /acme --work-dir=/tmp --logs-dir=/tmp
