#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${TEST_DIR}/test_colors.sh"
bash "${TEST_DIR}/test_config.sh"
bash "${TEST_DIR}/test_router.sh"
