#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail


_restore_list_backups() {
    print_info "Available backups:"
    # shellcheck disable=SC2153  # BACKUP_PATH is a config variable
    ssh_run "ls -1t ${BACKUP_PATH}"
}

_restore_database() {
    local backup_path="$1"
    print_step "Restoring database..."
    # shellcheck disable=SC2153
    ssh_run "gunzip -c ${backup_path}/database.sql.gz | psql -U ${DB_USER} ${DB_NAME}"
    log_success "Database restored"
}

_restore_release() {
    local backup_path="$1"
    print_step "Restoring release files..."
    ssh_run "tar -xzf ${backup_path}/release.tar.gz -C ${DEPLOY_PATH}/releases"
    log_success "Release files restored"
}

cmd_restore() {
    log_setup
    config_load
    config_validate

    _restore_list_backups

    local backup_name
    read -rp "  Enter backup timestamp to restore: " backup_name

    # shellcheck disable=SC2153
    local backup_path="${BACKUP_PATH}/${backup_name}"

    local confirm
    read -rp "  Restore from ${backup_name}? This will overwrite current data. [y/N]: " confirm
    if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
        print_info "Restore cancelled"
        exit 0
    fi

    log_info "Restoring ${APP_NAME} from backup ${backup_name}..."

    _restore_database "$backup_path"
    _restore_release  "$backup_path"

    log_success "Restore complete from ${backup_name}"
}

cmd_restore
