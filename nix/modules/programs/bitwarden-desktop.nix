{
  flake.nixosModules.bitwarden-desktop = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.bitwarden-desktop
    ];
  };
}
