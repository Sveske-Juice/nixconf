{
  # TODO: write hjem module (hjem-rum) for obsidian
  flake.nixosModules.obsidian = {pkgs, ...}: {
    allowedUnfreePackages = [
      "obsidian"
    ];

    environment.systemPackages = [
      pkgs.obsidian
    ];
  };
}
