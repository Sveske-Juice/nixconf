{
  flake.nixosModules.pcmanfm-qt = {pkgs, ...}: {
    services.gvfs.enable = true;

    environment.systemPackages = [
      pkgs.pcmanfm-qt
    ];
  };
}
