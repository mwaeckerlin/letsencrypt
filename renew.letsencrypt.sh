#! /bin/bash -ex

certbot renew -n -a webroot --webroot-path=/acme
