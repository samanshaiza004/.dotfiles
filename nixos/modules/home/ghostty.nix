{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      font-size = 11;
    };
  };
}
