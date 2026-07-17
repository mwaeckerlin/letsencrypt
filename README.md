# Standalone Image for Let's Encrypt

Standalone certificate acquisition and renewal. The image is **headless**: it
contains only the compiled ACME client [lego](https://go-acme.github.io/lego/)
and a small launcher — no shell, no Python, no cron.

It requests the certificates listed in `DOMAINS` and, when restarted, renews
them. It is a one-shot launcher, not a daemon: it obtains (or renews) the
certificates once and exits. Run unattended renewal by restarting the container
periodically (e.g. a swarm restart policy with an hourly delay).

## Configuration

- **`DOMAINS`** — space separated list of certificates; names sharing one
  certificate are separated by comma, e.g.
  `"domain1.com domain2.com a.domain3.com,b.domain3.com,c.domain3.com"`.
- **`PREFIXES`** — space separated prefixes prepended to every name (default
  `www`, so every domain also gets `www.<domain>`).
- **`EMAIL`** — ACME account e-mail (expiry notifications).
- **`MODE`** — `webroot` (default): the challenge token is written into `/acme`,
  which your webserver serves under `/.well-known/acme-challenge`; or
  `standalone`: lego answers the challenge itself on port `80`.
- **`OPTIONS`** — extra lego flags, e.g. `--server <acme-directory-url>`.

## Certificate layout

lego stores its files under `/etc/letsencrypt/certificates/`. For compatibility
with [mwaeckerlin/reverse-proxy](https://github.com/mwaeckerlin/reverse-proxy)
and the mail services — all of which read the classic layout — each certificate
is also published as:

- `/etc/letsencrypt/live/<domain>/fullchain.pem`
- `/etc/letsencrypt/live/<domain>/privkey.pem`

Mount a shared `/etc/letsencrypt` volume so the consuming services see the
certificates, and `/acme` if you use `webroot` mode.

This image is used with
[mwaeckerlin/reverse-proxy](https://github.com/mwaeckerlin/reverse-proxy);
check there for a full sample.

## Migration from the certbot-based version

- The client changed from **certbot to lego**; the image is now headless
  (no shell / Python / cron).
- The environment variables (`DOMAINS`, `PREFIXES`, `EMAIL`, `MODE`, `OPTIONS`)
  are unchanged, except that `OPTIONS` now takes **lego** flags (e.g.
  `--server <url>` instead of certbot options).
- The published `/etc/letsencrypt/live/<domain>/{fullchain,privkey}.pem` layout
  is unchanged, so consumers need no change.
- Renewal is no longer driven by an internal cron; restart the container
  periodically instead.

## Tests

End-to-end tests run against a local [Pebble](https://github.com/letsencrypt/pebble)
ACME test server (`tests/`):

```bash
npm test
```
