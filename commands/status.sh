#!/usr/bin/env bash
# shellcheck disable=SC1091

set -euo pipefail

source "${HAWK_ROOT}/lib/colors.sh"
source "${HAWK_ROOT}/lib/log.sh"
source "${HAWK_ROOT}/lib/config.sh"
source "${HAWK_ROOT}/lib/ssh.sh"


cmd_status() {
    log_setup
    config_load
    config_validate

    print_step "Deployment status for ${APP_NAME}..."

    print_info "Current release:"
    ssh_run "readlink ${DEPLOY_PATH}/current"

    print_info "Available releases:"
    ssh_run "ls -1t ${DEPLOY_PATH}/releases"

    print_info "Service status:"
    ssh_run "systemctl status ${APP_NAME} --no-pager"
}

cmd_status
