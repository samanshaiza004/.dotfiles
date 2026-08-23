{ config, lib, pkgs, ... }:

{
  xdg.configFile."matugen/config.toml".source = ./matugen/config.toml;
  xdg.configFile."matugen/templates/ghostty-colors".source = ./matugen/templates/ghostty-colors;
  xdg.configFile."matugen/templates/quickshell-colors.qml".source = ./matugen/templates/quickshell-colors.qml;
  xdg.configFile."matugen/templates/palette.json".source = ./matugen/templates/palette.json;

  # The generated QML file is mutable; keep the module definition managed so
  # the relative import remains a valid singleton import after activation.
  xdg.configFile."quickshell/generated/qmldir".source = ./matugen/qmldir;

  home.activation.generateMatugenPalette = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    wallpaper=/home/saman/wallpapers/schoolrumble1.jpeg
    if [ -f "$wallpaper" ]; then
      mkdir -p "$HOME/.cache/matugen" "$HOME/.config/ghostty" "$HOME/.config/quickshell/generated"
      ${pkgs.matugen}/bin/matugen image --quiet "$wallpaper"
    fi
  '';
}
