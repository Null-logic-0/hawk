#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

source "${HAWK_ROOT}/lib/colors.sh"
source "${HAWK_ROOT}/lib/log.sh"

cmd_init() {
    log_setup

    if [[ -f "hawk.conf" ]]; then
        log_fatal "hawk.conf already exists. Remove it first."
    fi

    print_step "Initializing hawk configuration..."

    read -rp "  App name: " APP_NAME
    read -rp "  Server host: " SERVER_HOST
    read -rp "  Server user: " SERVER_USER
    read -rp "  Git repo: " GIT_REPO

    cp "${HAWK_ROOT}/templates/hawk.conf.example" hawk.conf

    sed -i.bak \
        -e "s|__APP_NAME__|${APP_NAME}|g" \
        -e "s|__SERVER_HOST__|${SERVER_HOST}|g" \
        -e "s|__SERVER_USER__|${SERVER_USER}|g" \
        -e "s|__GIT_REPO__|${GIT_REPO}|g" \
        hawk.conf

    rm -f hawk.conf.bak

    log_success "hawk.conf created"
    print_info "Next steps:"
    print_info "  Review hawk.conf and adjust any values"
    print_info "  Run 'hawk doctor' to verify your setup"
}

cmd_init
