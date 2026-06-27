#!/usr/bin/env bash
set -euo pipefail

HAWK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_RUN=0
TESTS_FAILED=0

# shellcheck disable=SC1091
source "${HAWK_ROOT}/lib/colors.sh"

assert_equals() {
    local expected="$1"
    local actual="$2"
    local description="$3"
    if [[ "$expected" == "$actual" ]]; then
        print_success "$description"
    else
        print_error "FAIL: $description"
        echo "  expected: $expected" >&2
        echo "  got:      $actual" >&2
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_contains() {
    local needle="$1"
    local haystack="$2"
    local description="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        print_success "$description"
    else
        print_error "FAIL: $description"
        echo "  expected to contain: $needle" >&2
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local description="$3"
    assert_equals "$expected" "$actual" "$description"
}

test_summary() {
    echo ""
    if [[ "$TESTS_FAILED" -eq 0 ]]; then
        print_success "All ${TESTS_RUN} tests passed"
    else
        print_error "${TESTS_FAILED}/${TESTS_RUN} tests failed"
        exit 1
    fi
}
