#!/usr/bin/env bash
# Run the letsencrypt e2e suite: bring up the local Pebble ACME test server and
# certbot (mwaeckerlin/letsencrypt), then verify certbot obtained a real
# certificate from Pebble.
# Usage: bash tests/run-e2e.sh [pytest-args...]
set -euo pipefail

COMPOSE="tests/e2e/docker-compose.yml"
cd "$(dirname "$0")/.."

cleanup() {
    docker compose -f "$COMPOSE" down -v --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

# Always start from a clean, defined state.
echo "==> Clean start (removing stale volumes/containers)..."
cleanup

echo "==> Building test stack..."
docker compose -f "$COMPOSE" build --quiet

echo "==> Starting Pebble and letsencrypt..."
docker compose -f "$COMPOSE" up -d --remove-orphans

echo "==> Running tests..."
EXIT=0
docker compose -f "$COMPOSE" run --build --rm test-runner "$@" || EXIT=$?

if [[ $EXIT -ne 0 ]]; then
    echo "==> Collecting logs on failure..."
    docker compose -f "$COMPOSE" logs 2>&1 | tail -160
fi

exit $EXIT
