{
  flake.nixosModules.hardware-metal-themata = {
    config,
    lib,
    modulesPath,
    pkgs,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd.availableKernelModules = ["xhci_pci" "nvme" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
      initrd.kernelModules = [ "evdi" ];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [ config.boot.kernelPackages.evdi ];
    };

    allowedUnfreePackages = [
      "broadcom-bt-firmware"
      "b43-firmware"
      "xone-dongle-firmware"
      "facetimehd-calibration"
      "facetimehd-firmware"
      "displaylink"
      "nvidia-settings"
      "nvidia-x11"
    ];
    environment.systemPackages = with pkgs; [
      displaylink
    ];
    services.hardware.bolt.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
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
        modesetting.enable = true;
        open = false;
        nvidiaSettings = true;
        powerManagement = {
          enable = false;
          finegrained = false;
        };
        prime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
          offload.enable = true;
          offload.enableOffloadCmd = true;
        };
      };
    };
  };
}
