{
  flake.nixosModules.hardware-metal-larry = {lib, config, modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "uas"
        "usbhid"
      ];
      initrd.kernelModules = [];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };
    hardware.enableRedistributableFirmware = true;
    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
