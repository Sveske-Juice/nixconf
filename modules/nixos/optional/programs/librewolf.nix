{
  flake.nixosModules.librewolf = {pkgs, ...}: {
    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
    };
  };
}
