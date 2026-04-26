{
  flake.nixosModules.spotify = {pkgs, ...}: {
    allowedUnfreePackages = [
      "spotify"
    ];
    environment.systemPackages = [
      pkgs.spotify
    ];
  };
}
