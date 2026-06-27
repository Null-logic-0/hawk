#!/usr/bin/env bash
# Run doctor checks on the server
# shellcheck disable=SC1091

set -euo pipefail

source "${HAWK_ROOT}/lib/colors.sh"
source "${HAWK_ROOT}/lib/log.sh"
source "${HAWK_ROOT}/lib/config.sh"
source "${HAWK_ROOT}/lib/ssh.sh"


_check_bash_version() {
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        log_fatal "hawk requires bash >= 4. Current: ${BASH_VERSION}"
    fi
    log_success "bash ${BASH_VERSION}"
}

_check_local_tools() {
    local missing=0

    for tool in git rsync ssh; do
        if ! command -v "$tool" &>/dev/null; then
            log_error "required tool not found: ${tool}"
            missing=$((missing + 1))
        else
            log_success "${tool} found"
        fi
    done

    if [[ "$missing" -gt 0 ]]; then
        log_fatal "Missing required tools"
    fi
}


_check_config() {
    config_load
    config_validate
    log_success "Configuration is valid"
}


_check_ssh() {
    ssh_test
}

_check_remote_tools() {
    local missing=0
    for tool in git mix systemctl; do
        if ! ssh_run "command -v ${tool}" &>/dev/null; then
            log_error "remote tool not found: ${tool}"
            missing=$((missing + 1))
        else
            log_success "remote: ${tool} found"
        fi
    done
    if [[ "$missing" -gt 0 ]]; then
        log_fatal "Missing required remote tools"
    fi
}

cmd_doctor() {
    log_setup

    print_step "Running hawk doctor..."

    print_step "Running local checks..."
    _check_bash_version
    _check_local_tools
    _check_config

    print_step "Running remote checks..."
    _check_ssh
    _check_remote_tools

    log_success "All checks passed"
}

cmd_doctor
