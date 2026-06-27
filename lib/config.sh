#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
set -euo pipefail

[[ -n "${HAWK_CONFIG_LOADED:-}" ]] && return 0
HAWK_CONFIG_LOADED=1

source "${HAWK_ROOT}/config/defaults.sh"


_find_config() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "${dir}/hawk.conf" ]]; then
            echo "${dir}/hawk.conf"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

config_load() {
    local config_file
    config_file="$(_find_config || true)"
    if [[ -z "$config_file" ]]; then
       log_fatal "No hawk.conf found. Please run 'hawk init' to create one."
    fi
    log_info "Loading config from ${config_file}"
    source "$config_file"
}

config_validate() {
    local errors=0
    for field in APP_NAME SERVER_HOST SERVER_USER; do
        if [[ -z "${!field:-}" ]]; then
            log_error "Missing required config field: ${field}"
            errors=$((errors + 1))
        fi
    done
    if [[ "$errors" -gt 0 ]]; then
        log_fatal "Configuration validation failed"
    fi
}

config_show() {
    print_info "Current hawk configuration:"
    print_info "APP_NAME: ${APP_NAME:-}"
    print_info "SERVER_HOST: ${SERVER_HOST:-}"
    print_info "SERVER_PORT: ${SERVER_PORT:-}"
    print_info "SERVER_USER: ${SERVER_USER:-}"
    print_info "GIT_BRANCH: ${GIT_BRANCH:-}"
    print_info "APP_ENV: ${APP_ENV:-}"
    print_info "RELEASES_TO_KEEP: ${RELEASES_TO_KEEP:-}"
    print_info "BACKUP_PATH: ${BACKUP_PATH:-}"
}
