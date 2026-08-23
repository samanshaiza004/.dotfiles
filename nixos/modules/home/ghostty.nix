{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      font-size = 16;
      background-opacity = 0.85;
      background-blur=16;
      config-file = "/home/saman/.config/ghostty/config-colors";
    };
  };
}
