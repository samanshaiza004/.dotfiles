{ config, lib, pkgs, ... }:

let
  ghosttyPaletteGenerator = pkgs.callPackage ./matugen/ghostty-palette-generator.nix { };
in
{
  xdg.configFile."matugen/config.toml".source = ./matugen/config.toml;
  xdg.configFile."matugen/templates/palette.json".source = ./matugen/templates/palette.json;

  home.packages = [ ghosttyPaletteGenerator ];

  home.activation.generateMatugenPalette = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    wallpaper=/home/saman/wallpapers/schoolrumble1.jpeg
    if [ -f "$wallpaper" ]; then
      mkdir -p "$HOME/.cache/matugen" "$HOME/.config/ghostty" "$HOME/.config/quickshell/generated"
      rm -f "$HOME/.config/quickshell/generated/MatugenColors.qml" "$HOME/.config/quickshell/generated/qmldir"
      ${pkgs.matugen}/bin/matugen image --quiet --source-color-index 0 "$wallpaper"
      ${ghosttyPaletteGenerator}/bin/ghostty-palette-generator "$wallpaper"
    fi
  '';
}
