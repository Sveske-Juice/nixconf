{
  flake.nixosModules.orca-slicer = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.orca-slicer
    ];
  };
}
