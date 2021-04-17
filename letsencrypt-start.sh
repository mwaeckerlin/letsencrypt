#! /bin/sh -ex

test -n "$DOMAINS"

for domain in ${DOMAINS}; do
    DOMAINLIST=$(for subdomain in ${domain//,/ }; do
        echo $subdomain
        for prefix in ${PREFIXES}; do
            echo $prefix.$subdomain
        done
    done | head -c -1 | tr '\n' ',')
    certbot certonly ${OPTIONS} -n --expand --agree-tos --${MODE:-webroot} -w /.well-known --work-dir /tmp -d "${DOMAINLIST}" ${EMAIL:+-m} ${EMAIL}
done

/entrypoint.sh
