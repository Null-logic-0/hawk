#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${TEST_DIR}/test_helper.sh"

if [[ -x /opt/homebrew/bin/bash ]]; then
    HAWK_BASH="/opt/homebrew/bin/bash"
elif [[ -x /usr/local/bin/bash ]]; then
    HAWK_BASH="/usr/local/bin/bash"
else
    HAWK_BASH="bash"
fi

hawk_output="$("$HAWK_BASH" "${HAWK_ROOT}/bin/hawk" help 2>&1)"
assert_contains "Usage:" "$hawk_output" "hawk help outputs usage"

version_output="$("$HAWK_BASH" "${HAWK_ROOT}/bin/hawk" version 2>&1)"
assert_contains "hawk v" "$version_output" "hawk version outputs version"

set +e
"$HAWK_BASH" "${HAWK_ROOT}/bin/hawk" unknown >/tmp/hawk-test-router-unknown.out 2>&1
unknown_status=$?
set -e
assert_exit_code "1" "$unknown_status" "hawk unknown exits with code 1"

help_output="$("$HAWK_BASH" "${HAWK_ROOT}/bin/hawk" --help 2>&1)"
assert_contains "Usage:" "$help_output" "hawk --help outputs usage"

test_summary
