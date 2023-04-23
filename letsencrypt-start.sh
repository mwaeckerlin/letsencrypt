#! /bin/sh -e

for domain in ${DOMAINS}; do
    DOMAINLIST=$(for subdomain in ${domain//,/ }; do
        echo $subdomain
        for prefix in ${PREFIXES}; do
            echo $prefix.$subdomain
        done
    done | head -c -1 | tr '\n' ',')
    if test -e /etc/letsencrypt/live/${domain}; then
        echo "Certificate exists: /etc/letsencrypt/live/${domain}"
    else
        echo certbot certonly ${OPTIONS} -n --expand --agree-tos --${MODE:-webroot} -w /acme --work-dir /tmp -d "${DOMAINLIST}" ${EMAIL:+-m} ${EMAIL}
        certbot certonly ${OPTIONS} -n --expand --agree-tos --${MODE:-webroot} -w /acme --work-dir /tmp -d "${DOMAINLIST}" ${EMAIL:+-m} ${EMAIL}
    fi
done

echo certbot renew ${OPTIONS} -n --agree-tos --${MODE:-webroot} --work-dir /tmp -w /acme ${EMAIL:+-m} ${EMAIL}
certbot renew ${OPTIONS} -n --agree-tos --${MODE:-webroot} --work-dir /tmp -w /acme ${EMAIL:+-m} ${EMAIL}

/entrypoint.sh
