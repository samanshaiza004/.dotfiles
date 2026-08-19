{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Home Manager for saman: generates ~/.config/mango/config.conf,
  # the autostart script, and the mango-session systemd user target.
  # useGlobalPkgs avoids a duplicate package universe (the home-manager
  # nixpkgs input follows the main one in flake.nix).
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.saman = import ../../home/saman/home.nix;
  };
}
