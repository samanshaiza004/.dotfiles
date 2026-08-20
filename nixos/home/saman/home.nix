{ config, lib, pkgs, ... }:

{
  home.username = "saman";
  home.homeDirectory = "/home/saman";
  home.stateVersion = "26.05";

  imports = [
    ../../modules/home/mango.nix
    ../../modules/home/ghostty.nix
    ../../modules/home/quickshell/quickshell.nix
  ];

  # programs.ghostty (in modules/home/ghostty.nix) adds ghostty itself.
  home.packages = with pkgs; [
    firefox
    opencode
  ];
}
