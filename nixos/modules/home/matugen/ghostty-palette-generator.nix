{ pkgs }:

pkgs.writeShellApplication {
  name = "ghostty-palette-generator";
  runtimeInputs = with pkgs; [
    matugen
    python3
  ];
  text = ''
    exec ${pkgs.python3}/bin/python3 ${./ghostty-palette-generator.py} "$@"
  '';
}
