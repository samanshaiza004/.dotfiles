{ config, lib, pkgs, ... }:

{
  xdg.configFile."matugen/config.toml".source = ./matugen/config.toml;
  xdg.configFile."matugen/templates/ghostty-colors".source = ./matugen/templates/ghostty-colors;
  xdg.configFile."matugen/templates/palette.json".source = ./matugen/templates/palette.json;

  home.activation.generateMatugenPalette = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    wallpaper=/home/saman/wallpapers/schoolrumble1.jpeg
    if [ -f "$wallpaper" ]; then
      mkdir -p "$HOME/.cache/matugen" "$HOME/.config/ghostty" "$HOME/.config/quickshell/generated"
      rm -f "$HOME/.config/quickshell/generated/MatugenColors.qml" "$HOME/.config/quickshell/generated/qmldir"
      ${pkgs.matugen}/bin/matugen image --quiet "$wallpaper"
    fi
  '';
}
