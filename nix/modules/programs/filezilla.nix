{
  flake.nixosModules.filezilla = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.filezilla
    ];
  };
}
