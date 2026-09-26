# Changelog

- 2026-09-26 **2.0.2**
    - The test suite installs its Python packages without a warning

- 2026-09-26 **2.0.1**
    - The image is published for amd64 and arm64 under one tag, built, tested and published automatically on every change and every week
    - The standalone mode, where lego answers the challenge itself, is covered by an end to end test
    - Image build no longer emits warnings (modernized instruction format)

- 2026-07-17 **2.0.0**
    - The image is now headless: the certificate client changed from certbot to the compiled ACME client lego, and the shell start script and cron were replaced by a small compiled launcher — no shell, no Python, no cron in the image.
    - Certificates are still published as `/etc/letsencrypt/live/<domain>/{fullchain,privkey}.pem`, so the reverse-proxy and the mail services keep working unchanged.
    - Unattended renewal is now done by restarting the container periodically instead of an internal cron.
    - Migration notes:
        - `OPTIONS` now takes lego flags (e.g. `--server <url>`) instead of certbot options.
        - `DOMAINS`, `PREFIXES`, `EMAIL`, `MODE` are unchanged.
