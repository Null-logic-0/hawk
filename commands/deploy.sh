#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

source "${HAWK_ROOT}/lib/colors.sh"
source "${HAWK_ROOT}/lib/log.sh"
source "${HAWK_ROOT}/lib/config.sh"
source "${HAWK_ROOT}/lib/ssh.sh"


_deploy_pull_code() {
    local release_path="$1"
    print_step "Cloning repository..."
    ssh_run "git clone --depth 1 --branch ${GIT_BRANCH} ${GIT_REPO} ${release_path}"
    log_success "Code cloned: ${GIT_BRANCH}"
}

_deploy_create_release() {
    local release_path="$1"
    print_step "Creating release directory..."
    ssh_run "test -d ${DEPLOY_PATH}"
    ssh_run "mkdir -p ${release_path}"
    log_success "Release directory created: ${release_path}"
}

cmd_deploy() {
    log_setup
    config_load
    config_validate

    local release_timestamp
    release_timestamp="$(date '+%Y%m%d%H%M%S')"

    local release_path
    release_path="${DEPLOY_PATH}/releases/${release_timestamp}"

    log_info "Starting deploy of ${APP_NAME} → ${SERVER_HOST}"
    log_info "Release: ${release_timestamp}"

    _deploy_create_release   "$release_path"
    _deploy_pull_code        "$release_path"
    _deploy_build_release    "$release_path"
    _deploy_migrate          "$release_path"
    _deploy_symlink          "$release_path"
    _deploy_restart
    _deploy_healthcheck
    _deploy_cleanup

    log_success "Deploy complete → ${release_path}"
}

cmd_deploy
