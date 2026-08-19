{ config, pkgs, ... }:

{
  networking.hostName = "nixos"; # Define your hostname.

  # Desktop networking via NetworkManager. wpa_supplicant
  # (networking.wireless.enable) is the standalone alternative — NixOS
  # documents these as mutually exclusive; keep one.
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
