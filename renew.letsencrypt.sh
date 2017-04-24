#! /bin/bash -ex

letsencrypt renew -n -a webroot --webroot-path=/acme
