#! /bin/bash -ex

sed 's,${DOMAINS},'"${DOMAINS}"',g;s,${HTTPS_PORT},'"${HTTPS_PORT}"',g;s,${HTTP_PORT},'"${HTTP_PORT}"',g;' /renew.sh > /etc/cron.monthly/renew-certificates
chmod +x /etc/cron.monthly/renew-certificates
/etc/cron.monthly/renew-certificates
cron -fL7
