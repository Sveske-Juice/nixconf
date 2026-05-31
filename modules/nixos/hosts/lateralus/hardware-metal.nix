{inputs, ...}: {
  flake.nixosModules.hardware-metal-lateralus = {lib, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga502
    ];

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };

    allowedUnfreePackages = [
      "nvidia-x11"
      "nvidia-settings"
    ];

    hardware.enableRedistributableFirmware = true;
  };
}
