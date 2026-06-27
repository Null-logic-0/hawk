#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail


cmd_init() {
    log_setup

    if [[ -f "hawk.conf" ]]; then
        log_fatal "hawk.conf already exists. Remove it first."
    fi

    print_step "Initializing hawk configuration..."

    read -rp "  App name: " APP_NAME
    read -rp "  Server host: " SERVER_HOST
    read -rp "  Server user: " SERVER_USER
    read -rp "  Deploy path [/var/www/${APP_NAME}]: " input_deploy_path
    read -rp "  Git repo: " GIT_REPO
    read -rp "  DB user: " DB_USER
    read -rp "  DB name: " DB_NAME
    read -rp "  Release module: " RELEASE_MODULE

    DEPLOY_PATH="${input_deploy_path:-/var/www/${APP_NAME}}"

    cp "${HAWK_ROOT}/templates/hawk.conf.example" hawk.conf

    sed -i.bak \
        -e "s|__APP_NAME__|${APP_NAME}|g" \
        -e "s|__SERVER_HOST__|${SERVER_HOST}|g" \
        -e "s|__SERVER_USER__|${SERVER_USER}|g" \
        -e "s|__GIT_REPO__|${GIT_REPO}|g" \
        -e "s|__DB_USER__|${DB_USER}|g" \
        -e "s|__DB_NAME__|${DB_NAME}|g" \
        -e "s|__RELEASE_MODULE__|${RELEASE_MODULE}|g" \
        -e "s|__DEPLOY_PATH__|${DEPLOY_PATH}|g" \
        hawk.conf

    rm -f hawk.conf.bak


    sed \
        -e "s|__APP_NAME__|${APP_NAME}|g" \
        -e "s|__SERVER_USER__|${SERVER_USER}|g" \
        -e "s|__DEPLOY_PATH__|${DEPLOY_PATH}|g" \
        "${HAWK_ROOT}/templates/hawk.service.tmpl" > "${APP_NAME}.service"

    log_success "hawk.conf created"
    log_success "${APP_NAME}.service created"
    print_info "Next steps:"
    print_info "  Review hawk.conf and adjust any values"
    print_info "  Copy ${APP_NAME}.service to /etc/systemd/system/ on your server"
    print_info "  Then run: systemctl enable ${APP_NAME} && systemctl start ${APP_NAME}"
    print_info "  Run 'hawk doctor' to verify your setup"
}

cmd_init
