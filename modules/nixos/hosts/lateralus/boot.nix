{
  flake.nixosModules.host-lateralus = {
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
