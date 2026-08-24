#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/nixos/modules/home/quickshell/shell"
test_config="$(mktemp -d)"
log_file="$(mktemp)"
trap 'rm -rf "$test_config" "$log_file"' EXIT

cp -R "$config/." "$test_config/"

rg -q 'AppCatalog' "$config/services/AppCatalog.qml" "$config/shell.qml"
rg -q 'target: "launcher"' "$config/launcher/StartMenu.qml"
rg -q 'function open\(\)|function close\(\)' "$config/launcher/StartMenu.qml"
rg -q 'StartButton' "$config/panel/PanelBar.qml"
rg -q 'DesktopEntries\.applications' "$config/services/AppCatalog.qml"
rg -q 'ScriptModel|objectProp: "id"' "$config/launcher/AppList.qml"
rg -q 'AppSearch\.rank' "$config/services/AppCatalog.qml"
rg -q 'FileView|watchChanges|JsonAdapter' "$config/services/ColorService.qml"
rg -q 'ColorService' "$config/style/Theme.qml"
rg -q 'Quickshell\.Bluetooth|Bluetooth\.defaultAdapter|beginDiscovery|stopDiscovery' "$config/services/BluetoothService.qml"
rg -q 'BluetoothService 1\.0 BluetoothService\.qml' "$config/services/qmldir"
rg -q 'BluetoothService' "$config/shell.qml"
rg -q 'BluetoothWidget|bluetoothService' "$config/panel/PanelBar.qml"
rg -q 'BluetoothMenu|popupController' "$config/panel/BluetoothWidget.qml"
rg -q 'discoveryTimer|requestedDiscovery|closeMenu' "$config/services/BluetoothService.qml"
rg -q 'ScriptModel|ObjectComparison\.Identity|membershipRevision' "$config/services/BluetoothService.qml"
rg -q 'onTrustedChanged|onBlockedChanged' "$config/services/BluetoothService.qml"
! rg -q 'onBatteryChanged|onPairingChanged' "$config/services/BluetoothService.qml"
rg -q 'model: root\.bluetoothService\.(connectedDevices|pairedDevices|availableDevices)' "$config/menus/BluetoothMenu.qml"
rg -q 'qs ipc call launcher toggle' "$repo_root/nixos/modules/home/mango.nix"

set +e
timeout 8 quickshell --no-color --path "$test_config" >"$log_file" 2>&1
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
