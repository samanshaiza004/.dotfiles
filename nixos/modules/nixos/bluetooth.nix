{ pkgs, ... }:

{
  # BlueZ is the authoritative Bluetooth backend used by Quickshell.Bluetooth.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Quickshell 0.3.1 can start simple native pairing, but does not provide a
  # BlueZ Agent1 UI for PIN/passkey/numeric-comparison requests. Keep Blueman
  # as an explicit escape hatch without starting its tray applet.
  environment.systemPackages = [ pkgs.blueman ];
}
