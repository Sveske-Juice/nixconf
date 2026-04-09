{
  flake.nixosModules.hardware-metal-themata = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd.availableKernelModules = ["xhci_pci" "nvme" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      initrd.kernelModules = [];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "broadcom-bt-firmware"
          "b43-firmware"
          "xone-dongle-firmware"
          "facetimehd-calibration"
          "facetimehd-firmware"
        ];
    };
    hardware = {
      enableAllFirmware = true;
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
