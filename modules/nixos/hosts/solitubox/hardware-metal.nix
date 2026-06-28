{self, ...}: {
  flake.nixosModules.hardware-metal-solitubox = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      self.nixosModules.driver-amdgpu
    ];

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "uas"
        "usbhid"
      ];
      initrd.kernelModules = [];
      kernelModules = ["kvm-amd"];
      extraModulePackages = [];
    };

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };
    hardware = {
      cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
