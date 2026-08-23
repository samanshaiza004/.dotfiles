{ config, lib, pkgs, ... }:

let
  late2000sSddmTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "late2000s-sddm-theme";
    version = "1.0.0";
    src = ./sddm-theme;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/sddm/themes/late2000s"
      cp -r ./* "$out/share/sddm/themes/late2000s/"
      runHook postInstall
    '';
  };
in
{
  # SDDM's stable greeter runs on X11; the selected user session remains Mango
  # on Wayland. These are separate display-server choices.
  services.xserver.enable = true;
  services.displayManager.defaultSession = "mango";
  services.displayManager.sddm = {
    enable = true;
    theme = "late2000s";
    wayland.enable = false;
  };

  environment.systemPackages = [ late2000sSddmTheme ];
}
