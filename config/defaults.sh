#!/usr/bin/env bash
set -euo pipefail
[[ -n "${HAWK_DEFAULTS_LOADED:-}" ]] && return 0
HAWK_DEFAULTS_LOADED=1



DEPLOY_PATH="${DEPLOY_PATH:-/var/www/app}"
GIT_BRANCH="${GIT_BRANCH:-main}"
SERVER_PORT="${SERVER_PORT:-22}"
APP_ENV="${APP_ENV:-production}"
RELEASES_TO_KEEP="${RELEASES_TO_KEEP:-5}"
BACKUP_PATH="${BACKUP_PATH:-/var/backups/hawk}"
