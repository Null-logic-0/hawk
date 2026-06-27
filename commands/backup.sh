#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2153
set -euo pipefail


_backup_create_dir() {
    local backup_path="$1"
    ssh_run "mkdir -p ${backup_path}"
    log_success "Backup directory created: ${backup_path}"
}

_backup_database() {
    local backup_path="$1"
    print_step "Backing up database..."
    ssh_run "pg_dump -U ${DB_USER} ${DB_NAME} | gzip > ${backup_path}/database.sql.gz"
    log_success "Database backed up → ${backup_path}/database.sql.gz"
}

_backup_release() {
    local backup_path="$1"
    print_step "Archiving current release..."
    ssh_run "tar -czf ${backup_path}/release.tar.gz -C ${DEPLOY_PATH}/releases \$(basename \$(readlink ${DEPLOY_PATH}/current))"
    log_success "Release archived → ${backup_path}/release.tar.gz"
}

cmd_backup() {
    log_setup
    config_load
    config_validate

    local backup_timestamp
    backup_timestamp="$(date '+%Y%m%d%H%M%S')"

    local backup_path="${BACKUP_PATH}/${backup_timestamp}"

    log_info "Starting backup of ${APP_NAME}..."

    _backup_create_dir "$backup_path"
    _backup_database   "$backup_path"
    _backup_release    "$backup_path"

    log_success "Backup complete → ${backup_path}"
}

cmd_backup
