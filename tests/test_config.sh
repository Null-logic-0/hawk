#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${TEST_DIR}/test_helper.sh"
# shellcheck disable=SC1091
source "${HAWK_ROOT}/lib/log.sh"
# shellcheck disable=SC1091
source "${HAWK_ROOT}/lib/config.sh"

unset APP_NAME SERVER_HOST SERVER_USER GIT_REPO DB_USER DB_NAME RELEASE_MODULE

set +e
( config_validate ) >/tmp/hawk-test-config-empty.out 2>&1
empty_status=$?
set -e
assert_exit_code "1" "$empty_status" "config_validate fails when required fields are empty"

# shellcheck disable=SC2034
APP_NAME="hawk-test"
# shellcheck disable=SC2034
SERVER_HOST="example.com"
# shellcheck disable=SC2034
SERVER_USER="deploy"
# shellcheck disable=SC2034
GIT_REPO="git@example.com:org/repo.git"
# shellcheck disable=SC2034
DB_USER="hawk"
# shellcheck disable=SC2034
DB_NAME="hawk_production"
# shellcheck disable=SC2034
RELEASE_MODULE="app"

set +e
config_validate >/tmp/hawk-test-config-valid.out 2>&1
valid_status=$?
set -e
assert_exit_code "0" "$valid_status" "config_validate passes when required fields are set"

test_summary
