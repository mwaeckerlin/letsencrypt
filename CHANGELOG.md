# Changelog

- 2026-07-17 **2.0.0**
    - The image is now headless: the certificate client changed from certbot to
      the compiled ACME client lego, and the shell start script and cron were
      replaced by a small compiled launcher — no shell, no Python, no cron in
      the image.
    - Certificates are still published as
      `/etc/letsencrypt/live/<domain>/{fullchain,privkey}.pem`, so the
      reverse-proxy and the mail services keep working unchanged.
    - Unattended renewal is now done by restarting the container periodically
      instead of an internal cron.
    - Migration notes:
        - `OPTIONS` now takes lego flags (e.g. `--server <url>`) instead of
          certbot options.
        - `DOMAINS`, `PREFIXES`, `EMAIL`, `MODE` are unchanged.
