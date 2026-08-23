#!/usr/bin/env bash
set -euo pipefail

system="$(nix build /etc/nixos#nixosConfigurations.saman.config.system.build.toplevel --no-link --print-out-paths 2>/dev/null)"
theme="$(nix-store -q --requisites "$system" | rg 'late2000s-sddm-theme-')"
sddm="$(nix eval --raw /etc/nixos#nixosConfigurations.saman.config.services.displayManager.sddm.package.outPath)"
session_data="$(nix eval --raw /etc/nixos#nixosConfigurations.saman.config.services.displayManager.sessionData.desktops)"
log_file="$(mktemp)"
cleanup() {
  rm -f "$log_file"
}
trap cleanup EXIT

test -f "$theme/share/sddm/themes/late2000s/Main.qml"
test -f "$theme/share/sddm/themes/late2000s/metadata.desktop"
test -f "$theme/share/sddm/themes/late2000s/theme.conf"
! rg -q 'import Quickshell|/home/saman|Matugen|wallpaper-set' "$theme/share/sddm/themes"
rg -q '^QtVersion=6$' "$theme/share/sddm/themes/late2000s/metadata.desktop"

test -f "$session_data/share/wayland-sessions/mango.desktop"
rg -q '^Name=Mango$' "$session_data/share/wayland-sessions/mango.desktop"
rg -q '^Exec=mango$' "$session_data/share/wayland-sessions/mango.desktop"

set +e
QT_QPA_PLATFORM=offscreen timeout 8 \
  "$sddm/bin/sddm-greeter-qt6" \
  --test-mode \
  --theme "$theme/share/sddm/themes/late2000s" \
  >"$log_file" 2>&1
status=$?
set -e

if [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
  cat "$log_file" >&2
  exit "$status"
fi

if rg -n 'Error|ERROR|Warning|WARNING|TypeError|ReferenceError|Unable|failed|Failed' "$log_file"; then
  cat "$log_file" >&2
  exit 1
fi

printf 'SDDM theme and Mango session test passed\n'
