{ config, lib, pkgs, ... }:

{
  home.username = "saman";
  home.homeDirectory = "/home/saman";
  home.stateVersion = "26.05";

  programs.fish = {
    enable = true;
    interactiveShellInit = "set -g fish_greeting";
  };

  imports = [
    ../../modules/home/mango.nix
    ../../modules/home/ghostty.nix
    ../../modules/home/matugen.nix
    ../../modules/home/quickshell/quickshell.nix
  ];

  # programs.ghostty (in modules/home/ghostty.nix) adds ghostty itself.
  home.packages = with pkgs; [
    firefox
    opencode
  ];
}
