{
  flake.nixosModules.hardware-vm-themata = {
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
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
