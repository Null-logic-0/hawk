#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2029
set -euo pipefail

source "${HAWK_ROOT}/lib/colors.sh"
source "${HAWK_ROOT}/lib/log.sh"
source "${HAWK_ROOT}/lib/config.sh"
source "${HAWK_ROOT}/lib/ssh.sh"

cmd_logs() {
    log_setup
    config_load
    config_validate

    local flag="${1:-}"

    if [[ "$flag" == "--follow" || "$flag" == "-f" ]]; then
        log_info "Streaming logs for ${APP_NAME} (Ctrl+C to exit)..."
        _ssh_opts

       ssh "${SSH_OPTS[@]}" "${SERVER_USER}@${SERVER_HOST}" \
                   "journalctl -u ${APP_NAME} -f --no-pager"

    else
        log_info "Last 100 lines of logs for ${APP_NAME}..."
        ssh_run "journalctl -u ${APP_NAME} -n 100 --no-pager"

    fi
}

cmd_logs "${@}"
