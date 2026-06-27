#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

source "${HAWK_ROOT}/lib/colors.sh"
source "${HAWK_ROOT}/lib/log.sh"
source "${HAWK_ROOT}/lib/config.sh"
source "${HAWK_ROOT}/lib/ssh.sh"

_rollback_get_previous() {
    local current
    current="$(ssh_run "basename \$(readlink ${DEPLOY_PATH}/current)" 2>/dev/null)"

    local previous
    previous="$(ssh_run "ls -1t ${DEPLOY_PATH}/releases | grep -A1 ${current} | tail -1" 2>/dev/null)"

    if [[ -z "$previous" ]]; then
        log_fatal "No previous release found to roll back to"
    fi

    if [[ "$previous" == "$current" ]]; then
        log_fatal "Only one release exists — cannot roll back"
    fi

    echo "$previous"
}

_rollback_switch() {
    local previous_path="$1"
    print_step "Switching to previous release..."
    ssh_run "ln -sfn ${previous_path} ${DEPLOY_PATH}/current"
    log_success "Symlink updated → ${previous_path}"

    print_step "Restarting service..."
    ssh_run_sudo "systemctl restart ${APP_NAME}"
    log_success "Service restarted"

    print_step "Running health check..."
    ssh_run "sleep 3"
    if ! ssh_run "systemctl is-active ${APP_NAME}" &>/dev/null; then
        log_fatal "Health check failed — ${APP_NAME} is not running after rollback"
    fi
    log_success "Service is healthy"
}

cmd_rollback() {
    log_setup
    config_load
    config_validate

    local current
    current="$(ssh_run "basename \$(readlink ${DEPLOY_PATH}/current)" 2>/dev/null)"

    local previous
    previous="$(_rollback_get_previous)"

    local previous_path="${DEPLOY_PATH}/releases/${previous}"

    log_info "Rolling back ${APP_NAME}..."
    log_info "From: ${current}"
    log_info "To:   ${previous}"

    _rollback_switch "$previous_path"

    log_success "Rollback complete → ${previous}"
}

cmd_rollback
