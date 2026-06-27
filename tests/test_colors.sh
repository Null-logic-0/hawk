#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${TEST_DIR}/test_helper.sh"

success_output="$(print_success "ok")"
assert_contains "✓" "$success_output" "print_success outputs a check mark"

error_output="$(print_error "bad")"
assert_contains "✗" "$error_output" "print_error outputs a cross mark"

test_summary
