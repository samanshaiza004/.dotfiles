{ config, pkgs, ... }:

let
  # nixpkgs still carries 0.3.0. Build the upstream 0.3.1 tag against the
  # exact Qt/private-API dependency set from this nixpkgs revision.
  quickshell = pkgs.quickshell.overrideAttrs (_: {
    version = "0.3.1";
    src = pkgs.fetchurl {
      url = "https://git.outfoxxed.me/quickshell/quickshell/archive/refs/tags/v0.3.1.tar.gz";
      hash = "sha256-1gWSYi8aocu4U9SBT2Bd/egnvGkr77/s/6zPTJDjUtg=";
    };
    cmakeFlags = [
      "-DDISTRIBUTOR:STRING=Nixpkgs"
      "-DINSTALL_QML_PREFIX:STRING=lib/qt-6/qml"
      "-DGIT_REVISION:STRING=tag-v0.3.1"
    ];
  });
in

{
  # Quickshell uses private Qt APIs, so this override intentionally reuses the
  # pinned nixpkgs dependency graph instead of importing another Qt universe.
  home.packages = with pkgs; [
    quickshell
    kdePackages.oxygen-icons
  ];

  # shell.qml + widgets live in ./shell; becomes ~/.config/quickshell.
  xdg.configFile."quickshell" = {
    source = ./shell;
    recursive = true;
  };
}
