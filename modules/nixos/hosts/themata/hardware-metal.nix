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

    allowedUnfreePackages = [
      "broadcom-bt-firmware"
      "b43-firmware"
      "xone-dongle-firmware"
      "facetimehd-calibration"
      "facetimehd-firmware"
    ];
    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };
    hardware = {
      enableAllFirmware = true;
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      graphics = {
        enable = true;
      };
      nvidia = {
        prime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
          offload.enable = true;
        };
      };
    };
  };
}
