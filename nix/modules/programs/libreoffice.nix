{
  flake.nixosModules.libreoffice = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.libreoffice-qt
      pkgs.hunspellDicts.da_DK
    ];
  };
}
