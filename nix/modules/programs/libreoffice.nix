{
  flake.nixosModules.libreoffice = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.libreoffice-qt6-fresh
      pkgs.hunspellDicts.da_DK
    ];
  };
}
