# make-wordpress

WordPress bundle for the XDS (`make-core`). Runs the official
`wordpress:php8.5-apache` image plus a `wpcli` helper service
(`wordpress:cli-php8.5`, profile `cli`, only started via `docker compose run`)
and a `wpcron` sidecar (external cron loop — `DISABLE_WP_CRON` is set, same
mechanics as production).

Expects the `mysql` bundle to be installed — the generated `compose.yaml`
adds the dependency automatically (see `compose.mysql.yaml`).

## Layout

| Path | Purpose |
|---|---|
| `${XO_WORDPRESS_ROOT}` (default `wordpress-core/`) | Full WordPress installation, bind-mounted to `/var/www/html`. Populated by the image entrypoint on first start. Gitignored. Seedable — `wordpress/` stays free for a project subrepo (theme/plugins via `subrepos.conf`). |
| `${XO_WORDPRESS_THEME_DIR}` (default `theme/`) | Your project theme, mounted into `wp-content/themes/${XO_WORDPRESS_THEME}`. This is the folder you commit. |
| `${XO_WORDPRESS_PLUGINS_DIR}` (default `plugins/`) | Mounted as the whole `wp-content/plugins/` — put your own plugins and composer-installed ones (wpackagist) here. |

## Proxy integration

If the `proxy` bundle is installed, `wordpress.install` registers the default
route (`docker/config/proxy/90-wordpress.conf.template`, `location /` →
`wordpress:80`). Set `XO_WORDPRESS_URL=https://<XO_SERVER_NAME>` so
`wordpress.setup` installs the site with the proxied URL; the direct port
(`XO_WORDPRESS_PORT`) stays available for debugging. `WORDPRESS_CONFIG_EXTRA`
handles `X-Forwarded-Proto` so HTTPS behind the proxy works without redirect
loops.

## Targets

```bash
make wordpress.setup                 # up + wp core install (idempotent) + theme activate
make wordpress.wp cmd="plugin list"  # any wp-cli command
make wordpress.bash                  # shell in the container
make wordpress.logs                  # container logs
make wordpress.cron.logs             # wpcron sidecar logs
```

`make init` runs `wordpress.setup`, so a fresh checkout is just:

```bash
make install && make start && make init
```

## Environment variables

Seeded once into `.env` (change them there, `make install` keeps your values):
`XO_WORDPRESS_PORT`, `XO_WORDPRESS_URL`, `XO_WORDPRESS_THEME`,
`XO_WORDPRESS_THEME_DIR`, `XO_WORDPRESS_PLUGINS_DIR`, `WORDPRESS_DB_*`,
`WORDPRESS_TITLE`, `WORDPRESS_ADMIN_*`, `WORDPRESS_DEBUG`.

`XO_WORDPRESS_ROOT` is seedable as well (default `wordpress-core/`).

## License

MIT License, Copyright (c) 2026 xebro GmbH. See [LICENSE](./LICENSE).
