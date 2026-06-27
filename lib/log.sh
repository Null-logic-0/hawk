#!/usr/bin/env bash
# shellcheck disable=SC1091

set -euo pipefail
[[ -n "${HAWK_LOG_LOADED:-}" ]] && return 0
HAWK_LOG_LOADED=1

source "${HAWK_ROOT}/lib/colors.sh"

HAWK_LOG_FILE="${HAWK_LOG_FILE:-/tmp/hawk.log}"

log_setup() {
    mkdir -p "$(dirname "${HAWK_LOG_FILE}")"
    {
        echo "========================================"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] hawk v${HAWK_VERSION:-unknown} — session started"
        echo "========================================"
    } >> "${HAWK_LOG_FILE}"
}

log_info()    { print_info "${1}";    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO    ${1}" >> "${HAWK_LOG_FILE}"; }
log_success() { print_success "${1}"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS ${1}" >> "${HAWK_LOG_FILE}"; }
log_warning() { print_warning "${1}"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING ${1}" >> "${HAWK_LOG_FILE}"; }
log_error()   { print_error "${1}" >&2; echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR   ${1}" >> "${HAWK_LOG_FILE}"; }
log_fatal()   { print_error "${1}" >&2; echo "[$(date '+%Y-%m-%d %H:%M:%S')] FATAL   ${1}" >> "${HAWK_LOG_FILE}"; exit 1; }

shellcheck -x: no issues
