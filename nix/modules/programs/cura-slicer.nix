{
  flake.nixosModules.cura-slicer = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.cura-appimage
    ];
  };
}
