# make-wordpress

WordPress bundle for the xebro dev-setup (`make-core`). Runs the official
`wordpress:php8.5-apache` image plus a `wpcli` helper service
(`wordpress:cli-php8.5`, profile `cli`, only started via `docker compose run`).

Expects the `mysql` bundle to be installed — the generated `compose.yaml`
adds the dependency automatically (see `compose.mysql.yaml`).

## Layout

| Path | Purpose |
|---|---|
| `${XO_WORDPRESS_ROOT}` (default `wordpress/`) | Full WordPress installation, bind-mounted to `/var/www/html`. Populated by the image entrypoint on first start. Gitignored. |
| `${XO_WORDPRESS_THEME_DIR}` (default `theme/`) | Your project theme, mounted into `wp-content/themes/${XO_WORDPRESS_THEME}`. This is the folder you commit. |

## Targets

```bash
make wordpress.setup                 # up + wp core install (idempotent) + theme activate
make wordpress.wp cmd="plugin list"  # any wp-cli command
make wordpress.bash                  # shell in the container
make wordpress.logs                  # container logs
```

`make init` runs `wordpress.setup`, so a fresh checkout is just:

```bash
make install && make start && make init
```

## Environment variables

Seeded once into `.env` (change them there, `make install` keeps your values):
`XO_WORDPRESS_PORT`, `XO_WORDPRESS_THEME`, `XO_WORDPRESS_THEME_DIR`,
`WORDPRESS_DB_*`, `WORDPRESS_TITLE`, `WORDPRESS_ADMIN_*`, `WORDPRESS_DEBUG`.

Forced on every `make install`: `XO_WORDPRESS_ROOT`.

## License

MIT License, Copyright (c) 2026 xebro GmbH. See [LICENSE](./LICENSE).
