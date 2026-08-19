{ config, pkgs, ... }:

{
  # Mango: lightweight dwl-based Wayland compositor
  programs.mango = {
    enable = true;
    addLoginEntry = true;
  };
}
