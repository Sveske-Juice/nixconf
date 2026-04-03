{
  flake.nixosModules.hostThemata = {
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

      loader.grub = {
        enable = true;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
      };
      loader.efi.canTouchEfiVariables = true;
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

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/6d465feb-ba25-4cbc-88ae-54fc5ac3957c";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/97A2-3DFC";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [
      {
        device = "/dev/disk/by-uuid/68adaddb-40da-418b-870f-3610518571d9";
      }
    ];
  };
}
