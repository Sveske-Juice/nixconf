{
  flake.nixosModules.remmina = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.remmina
    ];
  };
}
