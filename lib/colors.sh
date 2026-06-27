#!/usr/bin/env bash

set -euo pipefail

# Color constants

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'

# shellcheck disable=SC2034 # BOLD is a public constant, used by sourcing scripts
BOLD='\033[1m'
RESET='\033[0m'

if [[ -n "${NO_COLOR:-}" ]]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''

    # shellcheck disable=SC2034
    BOLD=''
    RESET=''
fi

print_success() {
    echo -e "${GREEN}  [✓] ${1}${RESET}"
}

print_error() {
    echo -e "${RED}  [✗] ${1}${RESET}"
}

print_warning() {
    echo -e "${YELLOW}  [⚠] ${1}${RESET}"
}

print_info() {
    echo -e "${CYAN}  [ℹ] ${1}${RESET}"
}

print_step() {
    echo -e "${BLUE}  [▶] ${1}${RESET}"
}


# print_success "Deployment complete"
# print_error "Connection failed"
# print_warning "Server is slow"
# print_info "Using config: hawk.conf"
# print_step "Pulling latest code"
