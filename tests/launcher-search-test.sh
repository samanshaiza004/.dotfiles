#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_config="$(mktemp -d)"
log_file="$(mktemp)"
trap 'rm -rf "$test_config" "$log_file"' EXIT

cp "$repo_root/tests/launcher-search-test.qml" "$test_config/test.qml"
cp "$repo_root/nixos/modules/home/quickshell/shell/launcher/AppSearch.js" "$test_config/AppSearch.js"

set +e
timeout 8 quickshell --no-color --path "$test_config/test.qml" >"$log_file" 2>&1
status=$?
set -e

if [[ "$status" -ne 0 ]]; then
  cat "$log_file" >&2
  exit "$status"
fi

if ! rg -q 'SEARCH_TEST_PASS' "$log_file"; then
  cat "$log_file" >&2
  exit 1
fi

if rg -q 'SEARCH_TEST_FAIL' "$log_file"; then
  cat "$log_file" >&2
  exit 1
fi

printf 'Launcher search tests passed\n'
