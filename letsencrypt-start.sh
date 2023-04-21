#! /bin/sh -e

for domain in ${DOMAINS}; do
    DOMAINLIST=$(for subdomain in ${domain//,/ }; do
        echo $subdomain
        for prefix in ${PREFIXES}; do
            echo $prefix.$subdomain
        done
    done | head -c -1 | tr '\n' ',')
    echo "**** installing certificates for: " ${DOMAINLIST}
    certbot certonly ${OPTIONS} -n --expand --agree-tos --${MODE:-webroot} -w /acme --work-dir /tmp -d "${DOMAINLIST}" ${EMAIL:+-m} ${EMAIL}
done

/entrypoint.sh
