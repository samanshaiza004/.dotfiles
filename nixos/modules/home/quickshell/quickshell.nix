{ config, pkgs, ... }:

{
  # quickshell 0.3.0 from the pinned nixpkgs: built against the same Qt
  # as the rest of the system (quickshell uses private Qt APIs, so the
  # nixpkgs match is what avoids ABI mismatch). Pinned via flake.lock —
  # not tracking master.
  home.packages = with pkgs; [
    quickshell
  ];

  # shell.qml + widgets live in ./shell; becomes ~/.config/quickshell.
  xdg.configFile."quickshell" = {
    source = ./shell;
    recursive = true;
  };
}
