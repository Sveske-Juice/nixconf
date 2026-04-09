{
  flake.nixosModules.host-themata = {
    boot = {
        loader.grub = {
          enable = true;
          device = "nodev";
          useOSProber = true;
          efiSupport = true;
        };
        loader.efi.canTouchEfiVariables = true;
    };
  };
}
