#! /bin/sh -ex

test -n "$DOMAINS"

export DOMAINLIST=$(for domain in ${DOMAINS}; do
    echo $domain
    for prefix in ${PREFIXES}; do
        echo $prefix.$domain
    done
done | head -c -1 | tr '\n' ',')

certbot certonly ${OPTIONS} -n --expand --agree-tos --${MODE:-webroot} -w /.well-known --work-dir /tmp -d "${DOMAINLIST}" ${EMAIL:+-m} ${EMAIL}

/entrypoint.sh
