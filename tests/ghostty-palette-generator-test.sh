#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
log_file="$(mktemp)"
cleanup() {
  rm -rf "$test_home" "$log_file"
}
trap cleanup EXIT

nix shell nixpkgs#python3 --command python3 - "$repo_root/nixos/modules/home/matugen/ghostty-palette-generator.py" <<'PY'
import importlib.util
import sys

spec = importlib.util.spec_from_file_location("generator", sys.argv[1])
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)

expected = {
    "#c95c54": "red",
    "#c7a85b": "yellow",
    "#7fa66a": "green",
    "#67a0a0": "cyan",
    "#6e93c4": "blue",
    "#9b79a8": "purple",
    "#777777": None,
}
for color, bucket in expected.items():
    assert generator.classify(color) == bucket, (color, generator.classify(color), bucket)
assert generator.best_foreground(generator.darken("#6e93c4")) == "#e9e6df"
PY

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
