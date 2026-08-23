#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_config="$(mktemp -d)"
log_file="$(mktemp)"
matugen_config="$test_config/matugen.toml"
cleanup() {
  rm -rf "$test_config" "$log_file"
  nix run nixpkgs#matugen -- image -c "$matugen_config" --quiet /home/saman/wallpapers/schoolrumble1.jpeg >/dev/null 2>&1 || true
}
trap cleanup EXIT

cp -R "$repo_root/nixos/modules/home/quickshell/shell/." "$test_config/"
cp "$repo_root/tests/color-service-test.qml" "$test_config/color-service-test.qml"
cat >"$matugen_config" <<EOF
[config]
version_check = false
fallback_color = "#6e93c4"
prefer = "closest-to-fallback"
source_color_index = 0

[config.wallpaper]
set = false
command = "true"

[templates.palette-json]
input_path = "$repo_root/nixos/modules/home/matugen/templates/palette.json"
output_path = "~/.config/quickshell/generated/palette.json"
EOF

nix run nixpkgs#matugen -- color hex -c "$matugen_config" --quiet "#263b73" >/dev/null

set +e
timeout 8 quickshell --no-color --path "$test_config/color-service-test.qml" >"$log_file" 2>&1 &
quickshell_pid=$!
set -e

sleep 0.45
nix run nixpkgs#matugen -- color hex -c "$matugen_config" --quiet "#b84a3a" >/dev/null

wait "$quickshell_pid" || true

if rg -q 'COLOR_TEST_FAIL|ERROR:|WARN' "$log_file" || ! rg -q 'COLOR_TEST_PASS' "$log_file"; then
  cat "$log_file" >&2
  exit 1
fi

printf 'ColorService file-watch test passed\n'
