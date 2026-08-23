#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/nixos/modules/home/quickshell/shell"
log_file="$(mktemp)"
trap 'rm -f "$log_file"' EXIT

set +e
timeout 8 quickshell --no-color --path "$config" >"$log_file" 2>&1
status=$?
set -e

# A timeout is expected because a successful shell is intentionally long-lived.
if [[ "$status" -ne 0 && "$status" -ne 124 ]]; then
  printf 'Quickshell exited with status %s\n' "$status" >&2
  cat "$log_file" >&2
  exit "$status"
fi

if rg -n 'ERROR: Failed to load configuration|ReferenceError:|Type .* unavailable|Cannot assign to non-existent' "$log_file"; then
  printf 'Quickshell smoke test found configuration errors\n' >&2
  exit 1
fi

printf 'Quickshell configuration loaded successfully\n'
