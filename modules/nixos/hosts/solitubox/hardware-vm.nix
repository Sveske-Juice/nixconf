{
  flake.nixosModules.hardware-vm-solitubox = {
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    boot.initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "sr_mod"
      "virtio_blk"
    ];

    boot.initrd.kernelModules = [
      "virtio_rng"
    ];

    # required for graphics in qemu
    virtualisation.vmVariantWithDisko = {
      virtualisation.memorySize = 4096;
      virtualisation.cores = 4;
      virtualisation.qemu.options = [
        "-device virtio-vga-gl"
        "-display gtk,gl=on"
      ];
    };

    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
