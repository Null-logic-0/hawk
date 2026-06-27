# Configuration

hawk reads deployment settings from a `hawk.conf` file. Generate one from your Phoenix project directory:

```bash
hawk init
```

The generated file is plain Bash variable assignment. Keep values simple, quote values that contain spaces, and do not commit secrets.

## File Lookup

hawk looks for `hawk.conf` in the current directory first. If it is not found, hawk walks up parent directories until it finds one.

This means you can run hawk from a project subdirectory:

```bash
cd apps/my_app
hawk status
```

If no config file is found, hawk exits with an error:

```text
No hawk.conf found. Please run 'hawk init' to create one.
```

## Example

```bash
APP_NAME=my_app
SERVER_HOST=example.com
SERVER_USER=deploy
SERVER_PORT=22
DEPLOY_PATH=/var/www/my_app
GIT_BRANCH=main
GIT_REPO=git@github.com:example/my_app.git
APP_ENV=production
RELEASES_TO_KEEP=5
RELEASE_MODULE=MyApp
BACKUP_PATH=/var/backups/my_app
DB_USER=my_app
DB_NAME=my_app_prod
```

## Reference

| Key | Default | Required | Description |
| --- | --- | --- | --- |
| `APP_NAME` | None | Yes | Phoenix release name and systemd service name. If your release command is `_build/prod/rel/my_app/bin/my_app`, this should be `my_app`. |
| `SERVER_HOST` | None | Yes | Hostname or IP address of the server. |
| `SERVER_USER` | None | Yes | SSH user hawk uses to run deploy commands. |
| `SERVER_PORT` | `22` | No | SSH port. |
| `DEPLOY_PATH` | `/var/www/app` | No | Base deployment directory on the server. hawk stores releases in `DEPLOY_PATH/releases` and points `DEPLOY_PATH/current` at the active release. |
| `GIT_BRANCH` | `main` | No | Branch cloned during deploy. |
| `GIT_REPO` | None | Yes | Git URL the server can clone. Use an SSH URL if the server authenticates with a deploy key. |
| `APP_ENV` | `production` | No | Application environment value stored in config. |
| `RELEASES_TO_KEEP` | `5` | No | Number of releases kept after cleanup. Older release directories are removed after a successful deploy. |
| `RELEASE_MODULE` | None | Yes | Elixir module that exposes release tasks. hawk runs `RELEASE_MODULE.Release.migrate()` during deploy. |
| `BACKUP_PATH` | `/var/backups/hawk` | No | Base directory for timestamped backups. |
| `DB_USER` | None | Yes | PostgreSQL user used by `pg_dump` and `psql`. |
| `DB_NAME` | None | Yes | PostgreSQL database used by backup and restore commands. |

## Required Fields

hawk validates these fields before commands that need a deployment config:

```bash
APP_NAME
SERVER_HOST
SERVER_USER
GIT_REPO
DB_USER
DB_NAME
RELEASE_MODULE
```

Run validation as part of the full environment check:

```bash
hawk doctor
```

## Deployment Paths

For `DEPLOY_PATH=/var/www/my_app`, hawk expects this structure on the server:

```text
/var/www/my_app/
├── current -> /var/www/my_app/releases/20260627183000
└── releases/
    ├── 20260627180000
    └── 20260627183000
```

Create the base directory before the first deploy:

```bash
ssh deploy@example.com "sudo mkdir -p /var/www/my_app/releases && sudo chown -R deploy:deploy /var/www/my_app"
```

## Release Module

hawk runs database migrations with:

```bash
_build/prod/rel/my_app/bin/my_app eval 'MyApp.Release.migrate()'
```

For that command to work, your Phoenix app needs a release module with a `migrate/0` function. See the Phoenix releases guide:

```text
https://hexdocs.pm/phoenix/releases.html
```

## Git Access

`GIT_REPO` must be cloneable from the server, not just from your laptop.

For a private GitHub repository, configure a deploy key on the server and use an SSH URL:

```bash
GIT_REPO=git@github.com:example/my_app.git
```

Check access from the server:

```bash
ssh deploy@example.com "git ls-remote git@github.com:example/my_app.git"
```

## Backups

Backups are stored under `BACKUP_PATH` in timestamped directories:

```text
/var/backups/my_app/
└── 20260627183000/
    ├── database.sql.gz
    └── release.tar.gz
```

The backup command uses:

```bash
pg_dump -U "$DB_USER" "$DB_NAME"
```

The restore command uses:

```bash
psql -U "$DB_USER" "$DB_NAME"
```

Make sure the server user can run both commands without interactive prompts.

## Common Issues

### Missing required field

If a required field is empty, hawk prints the missing key and exits:

```text
Missing required config field: GIT_REPO
Configuration validation failed
```

Set the value in `hawk.conf`, then rerun:

```bash
hawk doctor
```

### Server cannot clone the repository

If deploy fails during clone, check `GIT_REPO` from the server:

```bash
ssh deploy@example.com "git ls-remote git@github.com:example/my_app.git"
```

### Wrong release module

If migrations fail, verify `RELEASE_MODULE` matches the module that defines `Release.migrate/0`.

For example:

```bash
RELEASE_MODULE=MyApp
```
