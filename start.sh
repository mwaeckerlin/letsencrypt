#! /bin/sh -ex

if test "$LETSENCRYPT" = "off"; then
    exit 0
fi

crond -f -L /dev/stdout
