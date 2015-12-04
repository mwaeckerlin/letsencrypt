#! /bin/bash -ex

echo > /etc/cron.monthly/renew-certificates <<EOF
#! /bin/bash
/renew.sh ${LETSENCRYPT_OPTIONS} ${DOMAINS}
EOF
chmod +x /etc/cron.monthly/renew-certificates
/etc/cron.monthly/renew-certificates
cron -fL7
