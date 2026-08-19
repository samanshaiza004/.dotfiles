{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Mango: lightweight dwl-based Wayland compositor
  programs.mango = {
    enable = true;
    addLoginEntry = true;
  };

  # Home Manager for saman: generates ~/.config/mango/config.conf,
  # the autostart script, and the mango-session systemd user target.
  # useGlobalPkgs avoids a duplicate package universe (nixpkgs input
  # follows the main one in flake.nix).
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.saman = import ../../home/saman/home.nix;
  };
}
