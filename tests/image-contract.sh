#!/usr/bin/env bash
# Image contract: the letsencrypt image must be headless.
#
# Since the switch from certbot to lego the image ships only the compiled ACME
# client and the C++ launcher -- no shell, no Python, no cron. This checks that
# none of those interpreters is present, detecting them from outside (a headless
# image has no `ls` either, so a missing tool must be observed from the host).
#
# Usage: tests/image-contract.sh IMAGE...

set -uo pipefail

PASS=0
FAIL=0
declare -a FAILED_NAMES

_pass() { PASS=$((PASS + 1)); echo "  PASS  $1"; }
_fail() { FAIL=$((FAIL + 1)); FAILED_NAMES+=("$1"); echo "  FAIL  $1: $2"; }

_image_exists() {
    local image="$1"
    if docker image inspect "${image}" > /dev/null 2>&1; then
        return 0
    fi
    _fail "${image}_image_exists" "image not built — run 'npm run build' first"
    return 1
}

_no_interpreter() {
    local image="$1" path="$2" name="$3"
    shift 3
    if docker run --rm --pull=never --entrypoint "${path}" "${image}" "$@" > /dev/null 2>&1; then
        _fail "${image}_no_${name}" "${path} exists — image is not headless"
    else
        _pass "${image}_no_${name}"
    fi
}

echo "==> Image contract: headless images"

for image in "$@"; do
    _image_exists "${image}" || continue
    _no_interpreter "${image}" /bin/sh       sh       -c :
    _no_interpreter "${image}" /bin/bash     bash     -c :
    _no_interpreter "${image}" /bin/busybox  busybox  ls /
    _no_interpreter "${image}" /usr/bin/perl perl     -e 1
    _no_interpreter "${image}" /usr/bin/python  python  -c ""
    _no_interpreter "${image}" /usr/bin/python3 python3 -c ""
    _no_interpreter "${image}" /usr/sbin/crond crond   -h
done

echo ""
echo "==> Image contract results: ${PASS} passed, ${FAIL} failed"
if [[ ${FAIL} -gt 0 ]]; then
    echo "==> Failed contracts: ${FAILED_NAMES[*]}"
    exit 1
fi
