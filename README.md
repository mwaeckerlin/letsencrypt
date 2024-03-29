# Standalone Image for Let's Encrypt

Standalone certificate aquiry and renewal, requests certificates specified as space separated list in variable `DOMAINS` and tries to daily renew them. If you have subdomains in the same certificate, separate them by comma. E.g. `"domain1.com domain2.com a.domain3.com,b.domain.com,c.domain.com"`

If variable `PREFIXES` is specified, it automatically prepends the space separated content to all domains in the `DOMAINS`. By default, prepends `www.` to every domain.

Set variable `MODE` to `standalone` to run it as standalone webserver. Do so, if you don't run a webserver and you can expose port `80`.

If you alreay have a webserver, set `MODE` to `webroot` to let that webserver serve `/acme` from a directory, that you mount in `/acme`. So you share the same path with your webserver.

Specifiy your mail in `EMAIL` to get notified when certificates expire.

Additional Options, e.g. `--dry-run`, can be added in variable `OPTIONS`.

This image is used with [mwaeckerlin/reverse-proxy](https://github.com/reverse-proxy). Check there for a full sample.
