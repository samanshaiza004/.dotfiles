#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
log_file="$(mktemp)"
cleanup() {
  rm -rf "$test_home" "$log_file"
}
trap cleanup EXIT

nix shell nixpkgs#matugen nixpkgs#python3 --command env \
  HOME="$test_home" \
  python3 "$repo_root/nixos/modules/home/matugen/ghostty-palette-generator.py" \
  /home/saman/wallpapers/anime_188.jpg >"$log_file" 2>&1

palette="$test_home/.config/ghostty/config-colors"
test "$(rg -c '^palette = ' "$palette")" -eq 16
rg -q '^background = #050506$' "$palette"
rg -q '^foreground = #e9e6df$' "$palette"
rg -q '^cursor-color = #4a8bde$' "$palette"
rg -q '^palette = 1=#c95c54$' "$palette"
rg -q '^palette = 4=#4a8bde$' "$palette"
rg -q '^palette = 15=#ffffff$' "$palette"

printf 'Ghostty palette generator test passed\n'
