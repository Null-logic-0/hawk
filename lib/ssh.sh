#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034,SC2029
set -euo pipefail

[[ -n "${HAWK_SSH_LOADED:-}" ]] && return 0
HAWK_SSH_LOADED=1

_ssh_opts() {
    SSH_OPTS=(
        -p "${SERVER_PORT}"
        -o "StrictHostKeyChecking=no"
        -o "ConnectTimeout=10"
        -o "BatchMode=yes"
    )
}

ssh_run() {
    local remote_command="$1"
    _ssh_opts
    log_info "Running command: ${remote_command}"

    ssh "${SSH_OPTS[@]}" "${SERVER_USER}@${SERVER_HOST}" "${remote_command}"
    log_info "Command completed"
}

ssh_test() {
    log_info "Testing SSH connection"
    _ssh_opts
    if ssh "${SSH_OPTS[@]}" "${SERVER_USER}@${SERVER_HOST}" "echo OK" &>/dev/null; then
        log_success "SSH connection successful"
    else
        log_fatal "Cannot connect to ${SERVER_HOST}"
    fi
}


ssh_upload() {
    local local_file="$1"
    local remote_path="$2"
    _ssh_opts
    log_info "Uploading ${local_file} to ${SERVER_HOST}:${remote_path}"
    rsync -az --delete \
        -e "ssh ${SSH_OPTS[*]}" \
        "$local_file" \
        "${SERVER_USER}@${SERVER_HOST}:${remote_path}"
    log_info "Upload completed"
}

ssh_run_sudo() {
    local remote_command="$1"
    _ssh_opts
    log_info "Running sudo command: ${remote_command}"
    ssh "${SSH_OPTS[@]}" "${SERVER_USER}@${SERVER_HOST}" "sudo ${remote_command}"
    log_info "Command completed"
}
